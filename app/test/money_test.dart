import 'package:decimal/decimal.dart';
import 'package:faro/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  test('modo privacidad: oculta los importes', () {
    privacyMode = true;
    expect(formatEur(d('1234.56')), '•••• €');
    privacyMode = false;
    expect(formatEur(d('1234.56')), '1.234,56 €');
  });

  test('modo privacidad: los ejes de las gráficas tampoco enseñan cifras', () {
    privacyMode = true;
    expect(axisAmount(12345), '•••');
    expect(axisAmount(15000, thousands: true), '•••');
    privacyMode = false;
    expect(axisAmount(12345.4), '12345');
    expect(axisAmount(15000, thousands: true), '15k');
  });

  group('formatEur', () {
    test('separador de miles siempre (también con 4 cifras)', () {
      expect(formatEur(d('1234.56')), '1.234,56 €');
      expect(formatEur(d('2126.9848')), '2.126,98 €');
      expect(formatEur(d('685714.285')), '685.714,29 €');
      expect(formatEur(d('1000000')), '1.000.000,00 €');
    });
    test('negativos, cero y signo +', () {
      expect(formatEur(d('-516.18')), '−516,18 €');
      expect(formatEur(d('0')), '0,00 €');
      expect(formatEur(d('516.18'), showPlus: true), '+516,18 €');
      expect(formatEur(d('-0.004')), '0,00 €');
    });
  });

  group('parseEsDecimal', () {
    test('formato español', () {
      expect(parseEsDecimal('1.234,56'), d('1234.56'));
      expect(parseEsDecimal('-12,5'), d('-12.5'));
      expect(parseEsDecimal('1.234'), d('1234'));
      expect(parseEsDecimal(' 14,30 € '), d('14.30'));
    });
    test('punto decimal sin ambigüedad e inválidos', () {
      expect(parseEsDecimal('12.50'), d('12.50'));
      expect(parseEsDecimal('abc'), isNull);
      expect(parseEsDecimal(''), isNull);
    });
  });
}
