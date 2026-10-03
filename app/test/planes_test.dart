import 'package:faro/features/planes/data.dart';
import 'package:faro/features/planes/compare_page.dart';
import 'package:faro/features/planes/planes_page.dart';
import 'package:faro/features/inversiones/data.dart' show portfolioProvider;
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

FireSettingsOut settings({bool configured = true, String spend = '2500.00'}) => FireSettingsOut(
      configured: configured, targetAge: 42, monthlySpend: spend, swr: '0.0325', nominalReturn: '0.07',
      inflation: '0.025', costs: '0.002', contributionGrowth: '0', pensionMonthly: '0.00', pensionAge: 67,
      includeTaxes: true, homeValue: '0.00', volatility: '0.15', horizonAge: 95, capitalOverride: null,
      contributionOverride: null,
    );

FireResultOut result(String fiAge) => FireResultOut(
      realReturn: '0.0419', needed: '1000000.00', neededNominal: '1484000.00', progress: '0.0021',
      requiredMonthly: '2400.00', fiAge: fiAge, coast: '500000.00', coastReached: false, bridge: '0.00',
    );

Future<void> pump(WidgetTester tester, {bool configured = true, String tab = 'independencia', List<GoalOut> goals = const []}) async {
  tester.view.physicalSize = const Size(420, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(), // un contenedor nuevo en cada pump
    overrides: [
      fireSettingsProvider.overrideWith((ref) async => settings(configured: configured)),
      firePlanProvider.overrideWith((ref) async => FirePlanOut(
            settings: settings(), age: '31.55', capital: '19964.25', capitalAuto: '19964.25',
            monthlyContribution: '500.00', contributionAuto: '500.00', cyclesUsed: 3, avgSpend: '1500.00',
            gainRatio: '0.6', grossAnnual: '33500.00', taxAnnual: '3500.00', base_: result('47.5'),
            pessimistic: result('52.0'), optimistic: result('44.0'),
            projection: [
              ProjectionPointOut(age: '31.55', pessimistic: '19500', base_: '19964', optimistic: '20400'),
              ProjectionPointOut(age: '32.55', pessimistic: '29000', base_: '30500', optimistic: '32000'),
            ],
            cutEffect: [CutEffectOut(cut: '100.00', fiAge: '46.25')],
          )),
      goalsProvider.overrideWith((ref) async => goals),
      taxPrefillProvider.overrideWith((ref) async => TaxPrefillOut(year: 2026, payrollNet: '18450.00',
          baseGeneral: null, realizedGains: '120.50', income: '30.00', baseSavings: '150.50', sales: 2)),
      portfolioProvider.overrideWith((ref) async => PortfolioOut(
            value: '0', cost: '0', pnl: '0', pnlPct: '0', pending: '0', stale: 0, classes: const [],
            unclassified: const [], emergency: null,
          )),
    ],
    child: MaterialApp(home: PlanesPage(tab: tab)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  test('edad legible', () {
    expect(ageText('47.5'), '47 años y 6 meses');
    expect(ageText('42.0'), '42 años');
  });

  testWidgets('FIRE configurado: frase, tres preguntas, Coast FIRE y recortes', (tester) async {
    await pump(tester);
    // La respuesta en una frase (sin céntimos a partir de 10.000 €) y los supuestos editables arriba
    expect(find.descendant(of: find.byKey(const Key('fire-needed')), matching: find.text('1.000.000 €')), findsOneWidget);
    expect(find.textContaining('para vivir con 2.500,00 €/mes netos a los 42'), findsOneWidget);
    expect(find.byKey(const Key('chip-spend')), findsOneWidget);
    expect(find.byKey(const Key('chip-contribution')), findsOneWidget);
    // Tres preguntas
    expect(find.text('A los 47 años y 6 meses'), findsOneWidget);
    expect(find.text('2.400,00 €/mes'), findsOneWidget);
    expect(find.text('3.500,00 €/año'), findsOneWidget);
    expect(find.textContaining('Retirarías 33.500,00 €/año en bruto'), findsOneWidget);
    // Coast FIRE explicado y "si recortas gastos" en años antes
    expect(find.text('Si hoy tuvieras 500.000 €, sin aportar más llegarías a los 42.'), findsOneWidget);
    expect(find.text('1 año y 3 meses antes'), findsOneWidget);
    expect(find.byKey(const Key('how-it-works')), findsOneWidget);
    // Tocar un supuesto abre su editor
    await tester.tap(find.byKey(const Key('chip-age')));
    await tester.pumpAndSettle();
    expect(find.text('Edad objetivo'), findsWidgets);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('comparar: tabla ahora / alternativa', (tester) async {
    FirePlanOut plan(String spend, String needed, String required, String? fiAge) => FirePlanOut(
          settings: settings(spend: spend), age: '31.55', capital: '19964.25', capitalAuto: '19964.25',
          monthlyContribution: '1000.00', contributionAuto: '1000.00', cyclesUsed: 3, avgSpend: null,
          gainRatio: null, grossAnnual: '0', taxAnnual: '0.00',
          base_: FireResultOut(realReturn: '0.0419', needed: needed, neededNominal: needed, progress: '0',
              requiredMonthly: required, fiAge: fiAge, coast: '0', coastReached: false, bridge: '0'),
          pessimistic: result('50'), optimistic: result('45'), projection: const [], cutEffect: const [],
        );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompareTable(
          now: plan('3500', '1292308.00', '4786.00', '67.1'),
          alt: plan('2500', '923077.00', '3414.00', '60.6'),
        ),
      ),
    ));
    expect(find.text('Ahora'), findsOneWidget);
    expect(find.text('3.500,00 €'), findsOneWidget);
    expect(find.text('1.292.308,00 €'), findsOneWidget);
    expect(find.text('923.077,00 €'), findsOneWidget);
    expect(find.text('3.414,00 €/mes'), findsOneWidget);
    expect(find.text('60 años y 7 meses'), findsOneWidget);
  });

  testWidgets('primera vez: preguntas del plan', (tester) async {
    await pump(tester, configured: false);
    expect(find.text('¿Cuándo quieres ser libre financieramente?'), findsOneWidget);
    expect(find.byKey(const Key('fire-spend')), findsOneWidget);
    expect(find.byKey(const Key('fire-birth')), findsOneWidget); // selector de fecha, no texto libre
    expect(find.text('Elegir fecha'), findsOneWidget);
  });

  testWidgets('impuestos: para qué sirve, prellenado con tus datos y "¿y si vendo?"', (tester) async {
    await pump(tester, tab: 'impuestos');
    expect(find.text('¿Para qué sirve?'), findsOneWidget);
    expect(find.textContaining('Tu nómina neta 2026: 18.450,00 €'), findsOneWidget);
    expect(find.textContaining('ganancias de 2 ventas +120,50 € (FIFO)'), findsOneWidget);
    expect(find.text('150,50'), findsOneWidget); // base del ahorro prellenada
    expect(find.text('Toda la cartera'), findsOneWidget);
    expect(find.byKey(const Key('to-tax-report')), findsOneWidget);
    // Sin base general, "¿y si vendo?" no calcula (el impuesto saldría más bajo de lo real)
    expect(find.byKey(const Key('sell-needs-base')), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('sell-calc'))).onPressed, isNull);
  });

  testWidgets('objetivos: vacío con ejemplo; con datos, editar y borrar visibles', (tester) async {
    await pump(tester, tab: 'objetivos');
    expect(find.text('Sin objetivos'), findsOneWidget);
    await pump(tester, tab: 'objetivos', goals: [
      GoalOut(id: 'g1', kind: GoalOutKindEnum.patrimonio, name: 'Patrimonio 50k', targetValue: '50000',
          targetDate: null, current: '27332.35', progress: '0.5466', onTrack: true, detail: 'Patrimonio neto'),
    ]);
    expect(find.text('En camino'), findsOneWidget);
    expect(find.byKey(const Key('goal-edit-g1')), findsOneWidget);
    expect(find.byKey(const Key('goal-delete-g1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('goal-edit-g1')));
    await tester.pumpAndSettle();
    expect(find.text('Editar objetivo'), findsOneWidget);
  });

  testWidgets('interés compuesto: formulario con los componentes comunes', (tester) async {
    await pump(tester, tab: 'interes-compuesto');
    expect(find.byKey(const Key('ci-initial')), findsOneWidget);
    expect(find.byKey(const Key('ci-calc')), findsOneWidget);
    expect(find.text('Pon las cifras y pulsa Calcular'), findsOneWidget);
  });
}
