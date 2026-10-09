import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../local_ai_engine.dart';

/// Mic → 16 kHz mono WAV capture with a hard 30 s ceiling (C8).
///
/// Supports both hold-to-talk (start on press-down, stop on release) and
/// tap-to-toggle (Elder mode default per UI spec). Audio is deleted after
/// extraction unless the "Keep recordings" setting is on.
class VoiceCaptureService {
  static const Duration maxDuration = Duration(seconds: 30);

  final AudioRecorder _recorder;
  Timer? _hardStopTimer;
  DateTime? _startedAt;
  String? _activePath;

  /// Fires exactly once at the 30 s ceiling so the UI can show the ring
  /// finishing and auto-submit.
  final _hardStopController = StreamController<void>.broadcast();

  VoiceCaptureService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  Stream<void> get onHardStop => _hardStopController.stream;
  bool get isRecording => _startedAt != null;
  Duration get elapsed =>
      _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

  /// Mic permission — caller shows the explanation sheet first (H15).
  Future<bool> ensurePermission() => _recorder.hasPermission();

  /// Starts recording. Returns the future clip path. Throws [AiUnavailable]
  /// when permission is denied so the UI can drop to typed text.
  Future<String> start() async {
    if (!await ensurePermission()) {
      throw const AiUnavailable('Microphone permission denied');
    }
    final dir = await getTemporaryDirectory();
    final path = p.join(
        dir.path, 'capture_${DateTime.now().millisecondsSinceEpoch}.wav');
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
    _activePath = path;
    _startedAt = DateTime.now();
    _hardStopTimer = Timer(maxDuration, () {
      _hardStopController.add(null);
    });
    return path;
  }

  /// Stops and returns the clip. Call after [start] or on [onHardStop].
  Future<WavAudioClip?> stop() async {
    _hardStopTimer?.cancel();
    final path = _activePath;
    final startedAt = _startedAt;
    _activePath = null;
    _startedAt = null;
    if (path == null || startedAt == null) return null;
    await _recorder.stop();
    var duration = DateTime.now().difference(startedAt);
    if (duration > maxDuration) duration = maxDuration;
    return WavAudioClip(path: path, duration: duration);
  }

  /// Deletes the audio file after extraction. Callers skip this when the
  /// "Keep recordings" setting is enabled.
  Future<void> discard(WavAudioClip clip) async {
    final f = File(clip.path);
    if (await f.exists()) await f.delete();
  }

  Future<void> dispose() async {
    _hardStopTimer?.cancel();
    await _recorder.dispose();
    await _hardStopController.close();
  }
}
