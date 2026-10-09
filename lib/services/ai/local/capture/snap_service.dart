import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../local_ai_engine.dart';

/// Camera/gallery capture for Snap (C11).
///
/// Intents: [ImageIntent.reseta] and [ImageIntent.label] are helper-only;
/// [ImageIntent.monitor] (BP monitor LCD) is elder-friendly.
/// The image is discarded after confirm unless the user toggles "Attach".
class SnapService {
  final ImagePicker _picker;

  SnapService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Opens the camera with a bounded resolution — enough for LCD digits,
  /// small enough to keep inference fast.
  Future<FileImageInput?> snapPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return FileImageInput(path: file.path);
  }

  /// Picks an existing photo from the gallery.
  Future<FileImageInput?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return FileImageInput(path: file.path);
  }

  /// Deletes the source photo after confirm unless "Attach" was toggled.
  Future<void> discard(FileImageInput input) async {
    final f = File(input.path);
    if (await f.exists()) await f.delete();
  }
}
