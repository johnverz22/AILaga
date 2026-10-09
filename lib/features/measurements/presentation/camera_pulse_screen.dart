import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utilities/uuid_generator.dart';
import '../../../services/hardware/ppg_analyzer.dart';
import '../data/measurement_providers.dart';
import '../domain/measurement_entity.dart';
import '../domain/measurement_type.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Estimates pulse by measuring tiny brightness changes in a fingertip
/// held over the camera lens (camera PPG). Deterministic signal
/// processing — no AI. The estimate is shown to the caregiver, who
/// confirms before it is saved as a `pulse` measurement with
/// `sourceType: camera_estimate`.
class CameraPulseScreen extends ConsumerStatefulWidget {
  final String recipientId;

  const CameraPulseScreen({super.key, required this.recipientId});

  @override
  ConsumerState<CameraPulseScreen> createState() =>
      _CameraPulseScreenState();
}

enum _Phase { loading, denied, noCamera, error, measuring, done }

class _CameraPulseScreenState extends ConsumerState<CameraPulseScreen>
    with WidgetsBindingObserver {
  static const _measureDuration = Duration(seconds: 20);

  CameraController? _controller;
  final _analyzer = PpgAnalyzer();
  PpgEstimate? _estimate;
  _Phase _phase = _Phase.loading;
  String _errorMessage = '';
  DateTime? _measuringSince;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _teardownCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _teardownCamera();
    } else if (state == AppLifecycleState.resumed &&
        _phase == _Phase.measuring &&
        _controller == null) {
      _setup();
    }
  }

  Future<void> _teardownCamera() async {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
      await c.setFlashMode(FlashMode.off);
    } catch (_) {
      // Best-effort cleanup.
    }
    await c.dispose();
  }

  Future<void> _setup() async {
    setState(() => _phase = _Phase.loading);

    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _phase = _Phase.denied);
      return;
    }

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException {
      setState(() {
        _phase = _Phase.noCamera;
      });
      return;
    }
    final back = cameras.where(
        (c) => c.lensDirection == CameraLensDirection.back);
    if (back.isEmpty) {
      setState(() => _phase = _Phase.noCamera);
      return;
    }

    final controller = CameraController(
      back.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup:
          Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );
    try {
      await controller.initialize();
      // Torch makes the fingertip glow red — needed for a clean signal.
      try {
        await controller.setFlashMode(FlashMode.torch);
      } on CameraException {
        // Some devices have no flash — measurement may still work
        // in bright light.
      }
      await controller.startImageStream(_onFrame);
    } on CameraException catch (e) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.description ?? 'Could not start the camera.';
      });
      return;
    }

    if (!mounted) {
      await _teardownCamera();
      return;
    }
    _controller = controller;
    _analyzer.reset();
    _estimate = null;
    _measuringSince = DateTime.now();
    setState(() => _phase = _Phase.measuring);
  }

  void _onFrame(CameraImage image) {
    if (_phase != _Phase.measuring || !mounted) return;
    final v = _meanBrightness(image);
    if (v == null) return;
    _analyzer.addSample(DateTime.now().millisecondsSinceEpoch, v);

    // Re-evaluate roughly once a second.
    if (_measuringSince == null) return;
    final elapsed = DateTime.now().difference(_measuringSince!);
    if (elapsed.inMilliseconds % 1000 < 40) {
      final est = _analyzer.estimate();
      if (est != null) _estimate = est;
      if (elapsed >= _measureDuration || _analyzer.progress >= 1.0) {
        if (_estimate != null) _finish();
      }
      if (mounted && _phase == _Phase.measuring) setState(() {});
    }
  }

  /// Mean brightness of a camera frame. For YUV/NV21 the first plane is
  /// luminance; for BGRA the green channel tracks pulse best. Samples
  /// every 8th byte to keep the per-frame cost tiny.
  double? _meanBrightness(CameraImage image) {
    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return null;
    var sum = 0;
    var count = 0;
    if (image.format.group == ImageFormatGroup.bgra8888) {
      for (var i = 1; i < bytes.length; i += 32) {
        sum += bytes[i]; // green channel of every 8th pixel
        count++;
      }
    } else {
      for (var i = 0; i < bytes.length; i += 8) {
        sum += bytes[i];
        count++;
      }
    }
    return count == 0 ? null : sum / count;
  }

  void _finish() {
    _teardownCamera();
    setState(() => _phase = _Phase.done);
  }

  Future<void> _save() async {
    final est = _estimate;
    if (est == null) return;
    final now = DateTime.now().toUtc();
    await ref.read(measurementRepositoryProvider).create(
          MeasurementEntity(
            id: UuidGenerator.generate(),
            careRecipientId: widget.recipientId,
            measurementType: MeasurementType.pulse,
            value1: est.bpm,
            unit: 'bpm',
            measuredAt: now,
            recordedAt: now,
            sourceType: 'camera_estimate',
            sourceLabel: 'Camera (fingertip)',
            notes: 'Estimated with the camera. Not a medical device.',
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        title: const Text('Camera pulse'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: switch (_phase) {
            _Phase.loading => const Center(child: CircularProgressIndicator()),
            _Phase.denied => _message(
                icon: Symbols.no_photography_rounded,
                title: 'Camera access needed',
                body: 'Allow camera access to measure pulse.',
                actionLabel: 'Open settings',
                onAction: openAppSettings,
              ),
            _Phase.noCamera => _message(
                icon: Symbols.videocam_off_rounded,
                title: 'No camera found',
                body: 'This device has no usable back camera.',
              ),
            _Phase.error => _message(
                icon: Symbols.error_rounded,
                title: 'Camera problem',
                body: _errorMessage,
                actionLabel: 'Try again',
                onAction: _setup,
              ),
            _Phase.measuring => _measuringView(theme),
            _Phase.done => _doneView(theme),
          },
        ),
      ),
    );
  }

  Widget _measuringView(ThemeData theme) {
    final est = _estimate;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 160,
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreview(_controller!)
                : const ColoredBox(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 24),
        Text('Cover the camera and flash with your fingertip.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Keep still until the ring fills.',
            style: TextStyle(color: Color(0xFF5E5748))),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: _analyzer.progress,
                strokeWidth: 10,
                backgroundColor: const Color(0xFFD9D2C3),
                color: const Color(0xFF0B6B6B),
              ),
            ),
            Text(
              est != null && est.quality >= 0.4
                  ? '${est.bpm.round()} bpm'
                  : 'Reading…',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed:
                _estimate != null ? _finish : () => _finish(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _doneView(ThemeData theme) {
    final est = _estimate;
    if (est == null) {
      return _message(
        icon: Symbols.monitor_heart_rounded,
        title: 'No pulse found',
        body:
            'Could not detect a steady pulse. Try again in brighter light and cover the lens fully.',
        actionLabel: 'Try again',
        onAction: _setup,
      );
    }
    final good = est.quality >= 0.5;
    final inRange = est.bpm >= 35 && est.bpm <= 200;
    return Column(
      children: [
        const Spacer(),
        Icon(
          good ? Symbols.monitor_heart_rounded : Symbols.monitor_heart_rounded,
          size: 64,
          color: good ? const Color(0xFF0B6B6B) : const Color(0xFF9A5B00),
        ),
        const SizedBox(height: 16),
        Text('${est.bpm.round()}',
            style: theme.textTheme.displayLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const Text('bpm', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: good
                ? const Color(0xFF1B7F3B).withValues(alpha: 0.12)
                : const Color(0xFF9A5B00).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            good ? 'Steady reading' : 'Weak signal — retake if unsure',
            style: TextStyle(
              color:
                  good ? const Color(0xFF1B7F3B) : const Color(0xFF9A5B00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'This is an estimate, not a medical reading.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF5E5748)),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6B)),
            onPressed: inRange ? _save : null,
            icon: const Icon(Symbols.check_rounded),
            label: const Text('Save', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _setup,
            child: const Text('Try again', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: const Color(0xFF5E5748)),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6B6B)),
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
