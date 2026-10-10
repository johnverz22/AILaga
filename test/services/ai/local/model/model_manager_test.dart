import 'dart:io';

import 'package:ailaga/services/ai/local/model/model_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late ModelManager manager;

  const descriptor = ModelDescriptor(
    id: 'gemma4-e2b-generic',
    url: 'https://example.invalid/model.litertlm',
    displayName: 'Smart Assistant',
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('model_manager_test');
    manager = ModelManager(descriptor, modelDir: dir);
  });

  tearDown(() async {
    await manager.dispose();
    await dir.delete(recursive: true);
  });

  test('existingModelPath is null when the dir is empty', () async {
    expect(await manager.existingModelPath(), isNull);
    expect(await manager.isInstalled, isFalse);
  });

  test('existingModelPath finds the descriptor file', () async {
    final f = File('${dir.path}/gemma4-e2b-generic.litertlm');
    await f.writeAsBytes([1, 2, 3]);
    expect(await manager.existingModelPath(), f.path);
    expect(await manager.installedSizeBytes(), 3);
  });

  test('existingModelPath falls back to a foreign variant file', () async {
    // e.g. the GPU-optimised file downloaded before the default changed.
    final f = File('${dir.path}/gemma4-e2b-gpu.litertlm');
    await f.writeAsBytes([9]);
    expect(await manager.existingModelPath(), f.path);
    expect(await manager.isInstalled, isTrue);
    final status = await manager.currentStatus();
    expect(status.state, ModelInstallState.installed);
    expect(status.sizeBytes, 1);
  });

  test('existingModelPath prefers the descriptor file over foreign variants',
      () async {
    await File('${dir.path}/gemma4-e2b-gpu.litertlm').writeAsBytes([9]);
    final f = File('${dir.path}/gemma4-e2b-generic.litertlm');
    await f.writeAsBytes([1]);
    expect(await manager.existingModelPath(), f.path);
  });

  test('existingModelPath migrates a legacy .bin file', () async {
    final legacy = File('${dir.path}/gemma4-e2b-generic.bin');
    await legacy.writeAsBytes([1]);
    final path = await manager.existingModelPath();
    expect(path, endsWith('gemma4-e2b-generic.litertlm'));
    expect(await File(path!).exists(), isTrue);
    expect(await legacy.exists(), isFalse);
  });

  test('delete removes all model files including foreign variants',
      () async {
    await File('${dir.path}/gemma4-e2b-gpu.litertlm').writeAsBytes([9]);
    await File('${dir.path}/gemma4-e2b-generic.part').writeAsBytes([1]);
    await manager.delete();
    expect(await manager.existingModelPath(), isNull);
    expect(await manager.isInstalled, isFalse);
  });
}
