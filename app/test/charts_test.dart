import 'dart:io';
import 'dart:math' as math;

import 'package:faro/core/charts/charts.dart';
import 'package:faro/core/money.dart';
import 'package:faro/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serie de prueba reproducible (sin datos de nadie): crecimiento con ondas.
List<ChartPoint> _series(double base, double slope, {int days = 400, int every = 7}) => [
      for (var d = 0; d <= days; d += every)
        ChartPoint.at(DateTime(2025, 9, 1).add(Duration(days: d)), base + slope * d + 300 * math.sin(d / 40)),
    ];

Widget _gallery() => Builder(
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 24, children: [
          FaroLineChart(
            periods: true,
            table: false,
            series: [
              ChartSeries(id: 'v', label: 'Valor', area: true, points: _series(3000, 22)),
              ChartSeries(id: 'a', label: 'Aportado', dashed: true, stepped: true, width: 1.5, points: _series(3000, 20)),
            ],
          ),
          FaroLineChart(
            stacked: true,
            table: false,
            series: [
              ChartSeries(id: 'c', label: 'Cuentas', points: _series(7000, 4)),
              ChartSeries(id: 'i', label: 'Inversiones', points: _series(3000, 22)),
            ],
          ),
          FaroBarChart(
            table: false,
            average: 340,
            series: const [(id: 'f', label: 'Fondos', color: null), (id: 'c', label: 'Cripto', color: null)],
            groups: [
              for (var m = 1; m <= 12; m++)
                BarGroup(['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'][m - 1],
                    [m == 5 ? -100 : 300, m.isEven ? 40 : 0]),
            ],
          ),
          const FaroDonut(
            center: '27k €',
            centerCaption: 'Patrimonio',
            slices: [
              DonutSlice(id: 'a', label: 'Fondo mundial', value: 12000),
              DonutSlice(id: 'b', label: 'Refugio', value: 6800),
              DonutSlice(id: 'c', label: 'Cuenta de gastos', value: 2000),
            ],
          ),
          MonthHeatmap(
            cells: {
              2025: {for (var m = 9; m <= 12; m++) m: HeatCell(ret: (m - 10) / 100)},
              2026: {for (var m = 1; m <= 10; m++) m: HeatCell(ret: math.sin(m.toDouble()) / 30)},
            },
            yearTotals: const {2025: 0.021, 2026: 0.054},
          ),
        ]),
      ),
    );

void main() {
  group('ejes', () {
    test('valores redondos: el máximo cae en una marca (sin "27988" encima de "25000")', () {
      final s = niceScale(3000, 27988);
      expect(s.max, greaterThanOrEqualTo(27988));
      expect(s.isTick(s.max), isTrue);
      expect(s.interval % 1000, 0);
      final z = niceScale(4000, 12267, includeZero: true);
      expect(z.min, 0);
    });

    test('€ compactos', () {
      expect(compactEur(850), '850 €');
      expect(compactEur(1200), '1,2k €');
      expect(compactEur(15000), '15k €');
      expect(compactEur(1400000), '1,4M €');
      expect(compactEur(-2500), '−2,5k €');
      privacyMode = true;
      expect(compactEur(15000), '•••');
      privacyMode = false;
    });

    test('eje de fechas: etiquetas únicas y que caben', () {
      for (final (days, width) in [(10, 300.0), (90, 300.0), (400, 800.0), (730, 300.0), (3000, 900.0)]) {
        final from = DateTime(2024, 10, 4);
        final t = dateTicks(from, from.add(Duration(days: days)), width);
        final labels = t.ticks.map(t.label).toList();
        expect(labels.toSet().length, labels.length, reason: '$days días: $labels');
        expect(labels.length * 64, lessThanOrEqualTo(width + 64), reason: '$days días en $width px');
      }
    });

    test('periodos del selector', () {
      final now = DateTime(2026, 10, 2);
      expect(periodStart(ChartPeriod.ytd, now), DateTime(2026, 1, 1));
      expect(periodStart(ChartPeriod.m3, now), DateTime(2026, 7, 2));
      expect(periodStart(ChartPeriod.all, now), isNull);
    });
  });

  testWidgets('modo privacidad: sin cifras en los ejes', (tester) async {
    privacyMode = true;
    addTearDown(() => privacyMode = false);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 600,
          child: FaroLineChart(table: false, series: [ChartSeries(id: 'v', label: 'Valor', points: _series(3000, 22))]),
        ),
      ),
    ));
    expect(find.textContaining('k €'), findsNothing);
    expect(find.text('•••'), findsWidgets);
  });

  testWidgets('pocos datos: aviso en vez de una gráfica vacía', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FaroLineChart(series: [ChartSeries(id: 'v', label: 'Valor', points: [ChartPoint.at(DateTime(2026), 1)])]),
      ),
    ));
    expect(find.textContaining('Aún no hay datos suficientes'), findsOneWidget);
  });

  testWidgets('la leyenda oculta y muestra una serie', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FaroLineChart(series: [
            ChartSeries(id: 'v', label: 'Valor', points: _series(3000, 22)),
            ChartSeries(id: 'a', label: 'Aportado', points: _series(3000, 20)),
          ]),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('legend-a')));
    await tester.pump();
    final opacity = tester.widget<Opacity>(
        find.descendant(of: find.byKey(const Key('legend-a')), matching: find.byType(Opacity)));
    expect(opacity.opacity, lessThan(1));
  });

  for (final width in [390.0, 820.0, 1440.0]) {
    for (final dark in [false, true]) {
      // Los golden se generan y comprueban en Windows (al cerrar cada fase); en la CI (Linux) el
      // dibujo del texto y del suavizado cambia lo bastante como para dar falsos fallos.
      testWidgets('golden: gráficas a ${width.round()} px (${dark ? 'oscuro' : 'claro'})',
          skip: Platform.environment.containsKey('CI'), (tester) async {
        tester.view.physicalSize = Size(width, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? FaroTheme.dark() : FaroTheme.light(),
          home: Scaffold(body: _gallery()),
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/graficas_${width.round()}_${dark ? 'oscuro' : 'claro'}.png'),
        );
      });
    }
  }
}
