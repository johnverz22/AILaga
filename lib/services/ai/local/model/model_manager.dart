import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Describes a downloadable on-device model.
class ModelDescriptor {
  final String id;

  /// Download URL as a string (may come from --dart-define).
  final String url;

  /// Expected SHA-256 of the model file, hex-encoded. Null = skip check.
  final String? sha256;

  /// Display name shown in Settings (never the raw filename).
  final String displayName;

  const ModelDescriptor({
    required this.id,
    required this.url,
    this.sha256,
    required this.displayName,
  });
}

enum ModelInstallState {
  notInstalled,
  downloading,
  paused,
  verifying,
  installed,
  error,
}

/// Status object streamed to the UI.
class ModelStatus {
  final ModelInstallState state;

  /// 0.0–1.0 while downloading; null when unknown/not downloading.
  final double? progress;

  /// Real size in bytes — from the server's Content-Length during download,
  /// or from the file on disk once installed. Never hardcoded.
  final int? sizeBytes;

  final String? error;

  const ModelStatus({
    required this.state,
    this.progress,
    this.sizeBytes,
    this.error,
  });

  static const notInstalled = ModelStatus(state: ModelInstallState.notInstalled);
}

/// Manages the on-device model file: resumable download, SHA-256 verify,
/// free-space check, delete. The UI subscribes to [statusStream].
///
/// Download resume: partial bytes are kept in `<id>.part`; a retry sends a
/// Range header. Kill-app-mid-download resumes automatically on next start.
class ModelManager {
  final ModelDescriptor model;
  final Future<int?> Function()? _freeSpaceProbe;

  final _statusController = StreamController<ModelStatus>.broadcast();
  HttpClient? _client;
  bool _cancelRequested = false;
  Future<void>? _installInFlight;

  /// Last status emitted this session. While a download is in flight this is
  /// the truth — the filesystem (.part exists) can't tell "downloading" from
  /// "paused", so new stream subscribers must not get a stale status.
  ModelStatus? _lastStatus;

  ModelManager(this.model, {Future<int?> Function()? freeSpaceProbe})
      : _freeSpaceProbe = freeSpaceProbe;

  Stream<ModelStatus> get statusStream => _statusController.stream;

  Future<Directory> get _modelDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'ai_models'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> get _modelFile async =>
      File(p.join((await _modelDir).path, '${model.id}.bin'));

  /// Absolute path of the installed model file (for engine load).
  Future<String> get modelFilePath async => (await _modelFile).path;

  Future<File> get _partialFile async =>
      File(p.join((await _modelDir).path, '${model.id}.part'));

  Future<bool> get isInstalled async => (await _modelFile).exists();

  /// Real on-disk size once installed.
  Future<int?> installedSizeBytes() async {
    final f = await _modelFile;
    return await f.exists() ? await f.length() : null;
  }

  Future<ModelStatus> currentStatus() async {
    if (_installInFlight != null && _lastStatus != null) return _lastStatus!;
    final f = await _modelFile;
    if (await f.exists()) {
      return ModelStatus(
          state: ModelInstallState.installed, sizeBytes: await f.length());
    }
    final partial = await _partialFile;
    if (await partial.exists()) {
      return ModelStatus(
          state: ModelInstallState.paused,
          sizeBytes: await partial.length());
    }
    return ModelStatus.notInstalled;
  }

  /// Downloads the model, resuming from a .part file if present.
  ///
  /// Single-flight: a second call while a download is running returns the
  /// same future. Two concurrent installs would write the same .part file
  /// and interleave statuses — the cause of bouncing/resetting progress.
  Future<void> install() =>
      _installInFlight ??=
          _runInstall().whenComplete(() => _installInFlight = null);

  Future<void> _runInstall() async {
    _cancelRequested = false;
    IOSink? sink;
    var received = 0;
    int? total;
    var attempt = 0;
    const maxAttempts = 6;

    try {
      // An empty/malformed URL (e.g. unset --dart-define) must fail cleanly,
      // not crash inside Uri.parse with "No host specified in URI".
      final uri = Uri.tryParse(model.url);
      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'https' && uri.scheme != 'http')) {
        _emit(const ModelStatus(
            state: ModelInstallState.error, error: 'no_download_url'));
        return;
      }

      // HEAD to learn the real file size before writing anything.
      final totalBytes = await _headContentLength(uri);
      if (totalBytes != null && _freeSpaceProbe != null) {
        final free = await _freeSpaceProbe();
        if (free != null && free < totalBytes) {
          _emit(ModelStatus(
              state: ModelInstallState.error,
              sizeBytes: totalBytes,
              error: 'not_enough_space'));
          return;
        }
      }

      final partial = await _partialFile;
      var finished = false;

      // Attempt loop: a multi-GB download on mobile WILL hit dropped or
      // half-open connections. Each retry resumes from the .part file,
      // so a stall costs nothing but a reconnect.
      while (!finished) {
        attempt++;
        // Fresh client per attempt — a reset socket must not be reused.
        _client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 30)
          ..idleTimeout = const Duration(seconds: 30);
        try {
          var sinkStart =
              await partial.exists() ? await partial.length() : 0;
          if (totalBytes != null && sinkStart >= totalBytes) {
            await partial.delete();
            sinkStart = 0;
          }
          final request = await _client!.getUrl(uri);
          if (sinkStart > 0) {
            request.headers
                .set(HttpHeaders.rangeHeader, 'bytes=$sinkStart-');
          }
          final response = await request.close();

          if (response.statusCode ==
              HttpStatus.requestedRangeNotSatisfiable) {
            // Server can't serve that range — .part is stale. Restart.
            if (await partial.exists()) await partial.delete();
            continue;
          }
          if (response.statusCode >= 400 &&
              response.statusCode != 429 &&
              response.statusCode < 500) {
            _emit(ModelStatus(
                state: ModelInstallState.error,
                error: 'http_${response.statusCode}'));
            return;
          }
          if (response.statusCode >= 400) {
            // 429/5xx — server-side hiccup, worth retrying.
            throw HttpException('http_${response.statusCode}', uri: uri);
          }

          // Server ignored our Range header → restart from scratch.
          final resumed =
              sinkStart > 0 && response.statusCode == HttpStatus.partialContent;
          if (sinkStart > 0 && !resumed) {
            await partial.delete();
            sinkStart = 0;
          }

          final s = partial.openWrite(
              mode: resumed ? FileMode.append : FileMode.write);
          sink = s;
          received = resumed ? sinkStart : 0;
          total = response.contentLength > 0
              ? (resumed
                  ? sinkStart + response.contentLength
                  : response.contentLength)
              : totalBytes;

          // Emit immediately so the UI shows progress, then throttle —
          // one rebuild per chunk makes the indicator flicker.
          _emit(ModelStatus(
              state: ModelInstallState.downloading,
              progress: _frac(received, total),
              sizeBytes: total ?? received));
          var lastEmit = DateTime.now().millisecondsSinceEpoch;
          var sinceFlush = 0;

          // Stream.timeout: if no bytes arrive for 30 s the socket is
          // dead or the CDN stopped feeding — bail out and resume on a
          // fresh connection instead of hanging forever.
          await for (final chunk
              in response.timeout(const Duration(seconds: 30))) {
            s.add(chunk);
            received += chunk.length;
            sinceFlush += chunk.length;
            // Flush periodically — unawaited adds queue bytes in memory,
            // which balloons to GBs when the network outruns the disk.
            if (sinceFlush >= 4 * 1024 * 1024) {
              await s.flush();
              sinceFlush = 0;
            }
            if (_cancelRequested) {
              await s.flush();
              await s.close();
              sink = null;
              await _emitPaused(partial, received, total);
              return;
            }
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastEmit >= 200) {
              lastEmit = now;
              _emit(ModelStatus(
                  state: ModelInstallState.downloading,
                  progress: _frac(received, total),
                  sizeBytes: total ?? received));
            }
          }
          await s.flush();
          await s.close();
          sink = null;
          finished = true;
        } catch (e) {
          try {
            await sink?.flush();
            await sink?.close();
          } catch (_) {}
          sink = null;
          _client?.close();
          _client = null;

          // pause() closes the client mid-stream — a user pause, not a
          // failure.
          if (_cancelRequested) {
            await _emitPaused(partial, received, total);
            return;
          }
          if (attempt >= maxAttempts) {
            _emit(const ModelStatus(
                state: ModelInstallState.error,
                error: 'download_failed'));
            return;
          }
          // Keep the UI on the progress view while we back off and
          // resume from the .part file.
          _emit(ModelStatus(
              state: ModelInstallState.downloading,
              progress: _frac(received, total),
              sizeBytes: total ?? received));
          await Future<void>.delayed(
              Duration(seconds: attempt <= 5 ? 1 << attempt : 30));
          if (_cancelRequested) {
            await _emitPaused(partial, received, total);
            return;
          }
        }
      }

      // Verify checksum when we have one.
      if (model.sha256 != null) {
        _emit(ModelStatus(
            state: ModelInstallState.verifying,
            progress: 1.0,
            sizeBytes: total));
        final digest = await sha256.bind(partial.openRead()).first;
        if (digest.toString() != model.sha256!.toLowerCase()) {
          await partial.delete();
          _emit(ModelStatus(
              state: ModelInstallState.error,
              error: 'checksum_mismatch'));
          return;
        }
      }

      final dest = await _modelFile;
      await partial.rename(dest.path);
      _emit(ModelStatus(
          state: ModelInstallState.installed, progress: 1.0, sizeBytes: total));
    } catch (e) {
      if (_cancelRequested) {
        try {
          await sink?.flush();
          await sink?.close();
        } catch (_) {}
        final partial = await _partialFile;
        await _emitPaused(partial, received, total);
      } else {
        _emit(ModelStatus(
            state: ModelInstallState.error, error: e.toString()));
      }
    } finally {
      _client?.close();
      _client = null;
    }
  }

  /// Pauses an in-flight download. Partial bytes are kept for resume.
  void pause() {
    _cancelRequested = true;
    _client?.close();
  }

  /// Deletes the installed model and any partial download.
  /// Callers fall back to Basic mode — nothing else breaks.
  Future<void> delete() async {
    pause();
    final f = await _modelFile;
    if (await f.exists()) await f.delete();
    final partial = await _partialFile;
    if (await partial.exists()) await partial.delete();
    _emit(ModelStatus.notInstalled);
  }

  Future<int?> _headContentLength(Uri uri) async {
    // Own client — the attempt loop rotates _client per retry.
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final req = await client.headUrl(uri);
      final res = await req.close();
      await res.drain<void>();
      return res.contentLength > 0 ? res.contentLength : null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  /// Emits `paused` only if the .part file actually survived — delete()
  /// may have wiped it between pause() and this emit.
  Future<void> _emitPaused(File partial, int received, int? total) async {
    if (await partial.exists()) {
      _emit(ModelStatus(
          state: ModelInstallState.paused,
          progress: _frac(received, total),
          sizeBytes: total ?? received));
    } else {
      _emit(ModelStatus.notInstalled);
    }
  }

  double? _frac(int received, int? total) =>
      (total == null || total <= 0) ? null : received / total;

  void _emit(ModelStatus s) {
    _lastStatus = s;
    if (!_statusController.isClosed) _statusController.add(s);
  }

  Future<void> dispose() async {
    pause();
    await _statusController.close();
  }
}
