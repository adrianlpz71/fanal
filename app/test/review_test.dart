import 'package:faro/features/planes/data.dart';
import 'package:faro/features/planes/review_tab.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

QuarterMetricsOut metrics({String surplus = '1500.00', String spend = '4500.00', String? fireAge = '58.5'}) =>
    QuarterMetricsOut(
      cycles: 3, income: '6000.00', spend: spend, surplus: surplus, savingsRate: '0.25', fixedAvg: '900.00',
      portfolioStart: '11000.00', portfolioEnd: '12164.25', contributed: '1020.00', gain: '144.25', twr: '0.0121',
      networthStart: '26000.00', networthEnd: '27316.82', fireNeeded: '702661.14', fireProgress: '0.027',
      fireAge: fireAge, outOfRange: const ['Cripto por debajo'],
      goals: [ReviewGoalOut(name: 'Fondo de emergencia', progress: '0.91', onTrack: null)],
    );

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  testWidgets('revisión: trimestre pendiente, comparación con el anterior y preguntas', (tester) async {
    tester.view.physicalSize = const Size(420, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        quartersProvider.overrideWith((ref) async => [
              QuarterItemOut(quarter: '2026-Q4', label: 'T4 2026', inProgress: true, saved: false),
              QuarterItemOut(quarter: '2026-Q3', label: 'T3 2026', inProgress: false, saved: false),
            ]),
        reviewProvider.overrideWith((ref, q) async => QuarterReviewOut(
              quarter: q, label: 'T3 2026', start: DateTime(2026, 7, 1), end: DateTime(2026, 9, 30),
              inProgress: false, metrics: metrics(),
              previous: metrics(surplus: '1200.00', spend: '4800.00', fireAge: '59.0'), previousLabel: 'T2 2026',
              rising: [CategoryRiseOut(name: 'Ocio y social', amount: '300.00', previous: '120.00')],
              changed: '', nextSteps: '', savedAt: null,
            )),
      ],
      child: const MaterialApp(home: Scaffold(body: ReviewTab())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Te toca la revisión del T3 2026'), findsOneWidget);
    expect(find.text('Te sobró'), findsOneWidget);
    expect(find.text('+300,00 €'), findsOneWidget); // sobró 300 € más que en T2
    expect(find.text('−300,00 €'), findsOneWidget); // y gastó 300 € menos
    expect(find.text('Ocio y social'), findsOneWidget); // lo que más subió
    expect(find.text('antes 59 años'), findsOneWidget); // edad de independencia frente a la revisión anterior
    expect(find.text('Cripto por debajo'), findsOneWidget);
    expect(find.byKey(const Key('review-changed')), findsOneWidget);
    expect(find.text('Guardar revisión'), findsOneWidget);
  });
}
