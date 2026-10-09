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
  Future<void> install() async {
    _cancelRequested = false;
    _client = HttpClient();

    try {
      // HEAD to learn the real file size before writing anything.
      final totalBytes = await _headContentLength();
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
      var sinkStart = await partial.exists() ? await partial.length() : 0;
      if (totalBytes != null && sinkStart >= totalBytes) {
        await partial.delete();
        sinkStart = 0;
      }
      final request =
          await _client!.getUrl(Uri.parse(model.url));
      if (sinkStart > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$sinkStart-');
      }
      final response = await request.close();

      if (response.statusCode >= 400) {
        _emit(ModelStatus(
            state: ModelInstallState.error,
            error: 'http_${response.statusCode}'));
        return;
      }
      // Server ignored our Range header → restart from scratch.
      final resumed = sinkStart > 0 && response.statusCode == 206;
      if (sinkStart > 0 && !resumed) {
        await partial.delete();
      }

      final sink = partial.openWrite(
          mode: resumed ? FileMode.append : FileMode.write);
      var received = resumed ? sinkStart : 0;
      final total = response.contentLength > 0
          ? (resumed ? sinkStart + response.contentLength : response.contentLength)
          : totalBytes;

      await for (final chunk in response) {
        if (_cancelRequested) {
          await sink.flush();
          await sink.close();
          _emit(ModelStatus(
              state: ModelInstallState.paused,
              progress: _frac(received, total),
              sizeBytes: total));
          return;
        }
        sink.add(chunk);
        received += chunk.length;
        _emit(ModelStatus(
            state: ModelInstallState.downloading,
            progress: _frac(received, total),
            sizeBytes: total));
      }
      await sink.flush();
      await sink.close();

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
      _emit(ModelStatus(
          state: ModelInstallState.error, error: e.toString()));
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

  Future<int?> _headContentLength() async {
    try {
      final req = await _client!.headUrl(Uri.parse(model.url));
      final res = await req.close();
      await res.drain<void>();
      return res.contentLength > 0 ? res.contentLength : null;
    } catch (_) {
      return null;
    }
  }

  double? _frac(int received, int? total) =>
      (total == null || total <= 0) ? null : received / total;

  void _emit(ModelStatus s) {
    if (!_statusController.isClosed) _statusController.add(s);
  }

  Future<void> dispose() async {
    pause();
    await _statusController.close();
  }
}
