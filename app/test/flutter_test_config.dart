import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las capturas de referencia (golden) se generan en Windows y la CI corre en Linux: el
/// suavizado de los bordes cambia unos pocos píxeles. Se admite hasta un 1 % de diferencia; un
/// cambio de diseño real (ejes, colores, posiciones) la supera de largo.
///
/// Texto grande (accesibilidad): `flutter test --dart-define=FARO_TEXT_SCALE=1.3` pasa todas las
/// pruebas con el texto del sistema al 130 %. Un desbordamiento ("RenderFlex overflowed") hace
/// fallar la prueba. Las capturas de referencia no se comparan en ese modo.
const _textScale = String.fromEnvironment('FARO_TEXT_SCALE');

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final current = goldenFileComparator;
  final scale = double.tryParse(_textScale);
  if (scale != null) {
    goldenFileComparator = _SkipComparator();
    setUp(() => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.textScaleFactorTestValue = scale);
  } else if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(Uri.parse('${current.basedir}flutter_test_config.dart'));
  }
  await testMain();
}

class _SkipComparator extends GoldenFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async => true;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {}
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const tolerance = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
