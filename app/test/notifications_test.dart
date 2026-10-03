import 'package:dio/dio.dart';
import 'package:faro/core/notifications.dart';
import 'package:faro/core/offline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('próximo cobro: el día del mes; si cae en fin de semana, el lunes', () {
    // Septiembre 2026: el 27 es domingo → lunes 28
    expect(nextPayday(DateTime(2026, 9, 10), 27), DateTime(2026, 9, 28));
    // Ya pasó este mes → el del mes siguiente (27 de octubre de 2026, martes)
    expect(nextPayday(DateTime(2026, 9, 29), 27), DateTime(2026, 10, 27));
    // Día 31 en febrero → último día del mes (28/02/2027 es domingo → lunes 1/03)
    expect(nextPayday(DateTime(2027, 2, 1), 31), DateTime(2027, 3, 1));
  });

  test('error de red frente a error de la API', () {
    final ro = RequestOptions(path: '/x');
    expect(isNetworkError(DioException(requestOptions: ro, type: DioExceptionType.connectionError)), isTrue);
    expect(
      isNetworkError(DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 422),
          type: DioExceptionType.badResponse)),
      isFalse,
    );
  });

  test('recordatorio de la revisión: primer día del trimestre siguiente', () {
    expect(nextQuarterStart(DateTime(2026, 10, 2)), DateTime(2027, 1, 1));
    expect(nextQuarterStart(DateTime(2026, 3, 31)), DateTime(2026, 4, 1));
    expect(nextQuarterStart(DateTime(2026, 4, 1)), DateTime(2026, 7, 1));
  });

  test('permiso de avisos: se pide una sola vez, al entrar, salvo que los hayas apagado', () {
    expect(shouldAsk(null, null), isTrue); // primera vez: se pide
    expect(shouldAsk(null, '1'), isFalse); // ya se pidió (aunque lo denegaras)
    expect(shouldAsk('0', null), isFalse); // los apagaste en Más
    expect(shouldAsk('1', null), isFalse); // los activaste tú desde Más (ya se pidió entonces)
    expect(avisosOn(null), isTrue);
    expect(avisosOn('0'), isFalse);
  });

  test('cada aviso abre una pantalla interna; nada de fuera', () {
    for (final r in AvisoRoute.all) {
      expect(isAvisoRoute(r), isTrue, reason: r);
    }
    expect(isAvisoRoute(null), isFalse);
    expect(isAvisoRoute('https://ejemplo.com'), isFalse);
    expect(isAvisoRoute('/login'), isFalse);
  });
}
