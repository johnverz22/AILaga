import 'package:flutter/services.dart';

/// Thin Dart wrappers over the iOS AilagaChannels (ios/Runner/
/// AilagaChannels.swift). All calls are defensive — off-platform or
/// channel-missing results degrade to "unavailable", never throw up.
///
/// Injectable seams ([respondImpl] etc.) exist so tests can stub the
/// channels without MethodChannel plumbing.
class AppleAiChannel {
  static const _channel = MethodChannel('com.ailaga.ailaga/apple_ai');

  static Future<Map<String, Object?>> availability() async {
    try {
      final res =
          await _channel.invokeMethod<Map<Object?, Object?>>('isAvailable');
      return {
        'available': res?['available'] == true,
        'reason': res?['reason']?.toString() ?? 'unknown',
      };
    } catch (_) {
      return {'available': false, 'reason': 'channel_unavailable'};
    }
  }

  static Future<bool> isAvailable() async =>
      (await availability())['available'] == true;

  static Future<String> respond(String prompt,
      {double? temperature}) async {
    final res = await _channel.invokeMethod<String>('respond', {
      'prompt': prompt,
      if (temperature != null) 'temperature': temperature,
    });
    if (res == null) {
      throw const AiChannelUnavailable('apple_ai returned null');
    }
    return res;
  }
}

class AppleSpeechChannel {
  static const _channel = MethodChannel('com.ailaga.ailaga/apple_speech');

  /// Transcribes a WAV file on-device. Returns the transcript, or null
  /// when unavailable/denied (caller falls back to typed input).
  static Future<String?> transcribe(String path) async {
    try {
      final res = await _channel
          .invokeMethod<Map<Object?, Object?>>('transcribe', {'path': path});
      final t = res?['transcript'];
      return t is String && t.isNotEmpty ? t : null;
    } catch (_) {
      return null;
    }
  }
}

class AppleVisionChannel {
  static const _channel = MethodChannel('com.ailaga.ailaga/apple_vision');

  /// OCRs an image file on-device. Returns extracted text, or null.
  static Future<String?> recognizeText(String path) async {
    try {
      final res = await _channel.invokeMethod<Map<Object?, Object?>>(
          'recognizeText', {'path': path});
      final t = res?['text'];
      return t is String && t.isNotEmpty ? t : null;
    } catch (_) {
      return null;
    }
  }
}

class AiChannelUnavailable implements Exception {
  final String message;
  const AiChannelUnavailable(this.message);
}
