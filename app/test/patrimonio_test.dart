import 'package:faro/features/inversiones/data.dart';
import 'package:faro/features/inversiones/panels.dart' show allTxProvider;
import 'package:faro/features/inversiones/performance_page.dart';
import 'package:faro/features/patrimonio/data.dart';
import 'package:faro/features/patrimonio/evolution_page.dart';
import 'package:faro/features/patrimonio/patrimonio_page.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

PerformanceMonthOut month(int m, String ret) => PerformanceMonthOut(
      year: 2026, month: m, startValue: '1000.00', endValue: '1100.00', netFlow: '0.00', gain: '100.00',
      ret: ret, cumulative: ret,
    );

EvolutionPointOut evPoint(DateTime d, {required String gastos, required String fondo, String contributed = '0.00',
        String installments = '0.00'}) {
  final acc = double.parse(gastos), inv = double.parse(fondo), inst = double.parse(installments);
  return EvolutionPointOut(
    date: d, accounts: gastos, investments: fondo, contributed: contributed, pending: '0.00', receivable: '0.00',
    debts: '0.00', installments: installments, net: (acc + inv - inst).toStringAsFixed(2),
    components: {'c:a': gastos, 'a:f': fondo},
  );
}

NetWorthEvolutionOut evolution() => NetWorthEvolutionOut(
      start: DateTime(2026, 7, 26),
      perCycleUntil: DateTime(2026, 8, 26),
      components: [
        NetWorthComponentOut(key: 'c:a', label: 'Banco', kind: NetWorthComponentOutKindEnum.cuenta, group: 'gastos',
            entity: 'Banco Demo'),
        NetWorthComponentOut(key: 'a:f', label: 'Fondo mundial', kind: NetWorthComponentOutKindEnum.inversion,
            group: 'fondo', entity: 'Broker Demo'),
      ],
      points: [
        evPoint(DateTime(2026, 7, 26), gastos: '900.00', fondo: '11000.00', contributed: '10500.00'),
        evPoint(DateTime(2026, 8, 26), gastos: '950.00', fondo: '11500.00', contributed: '10800.00'),
        evPoint(DateTime(2026, 9, 27), gastos: '1000.00', fondo: '11900.00', contributed: '11000.00'),
        evPoint(DateTime(2026, 10, 3), gastos: '1000.00', fondo: '12164.25', contributed: '11160.00'),
      ],
    );

MilestonesOut milestones() => MilestonesOut(
      thresholds: const ['10000.00', '12000.00', '25000.00'],
      items: [
        MilestoneOut(amount: '10000.00', reachedOn: DateTime(2026, 7, 26), beforeStart: true),
        MilestoneOut(amount: '12000.00', reachedOn: DateTime(2026, 8, 26), beforeStart: false),
        MilestoneOut(amount: '25000.00', reachedOn: null, beforeStart: false),
      ],
      next: MilestoneNextOut(amount: '25000.00', months: 15, eta: DateTime(2028, 1, 1)),
      pace: '865.00', net: '13164.25', start: DateTime(2026, 7, 26),
    );

void main() {
  test('tiempo invirtiendo legible (sin "1 año y 12 meses")', () {
    expect(spanText(728), '1 año y 11 meses');
    expect(spanText(731), '2 años');
    expect(spanText(400), '1 año y 1 mes');
    expect(spanText(45), '1 mes');
    expect(spanText(10), '0 meses');
  });

  setUpAll(() => initializeDateFormatting('es_ES'));
  scopeTests();

  testWidgets('patrimonio: neto, tras impuestos y resumen de la rentabilidad', (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        networthProvider.overrideWith((ref) async => NetWorthOut(
              total: '13164.25', accounts: [AccountBalanceOut(id: 'a', name: 'Banco', kind: 'gastos', balance: '1000.00')],
              investments: '12164.25', pending: '0.00', byType: const {'fondo': '10916.70'}, receivable: '0.00',
              debts: '0.00', installments: '0.00', unrealizedGain: '1004.25', taxIfSold: '190.81',
              afterTax: '12973.44', taxYear: 2026, taxSource: 'https://www.boe.es/x')),
        networthHistoryProvider.overrideWith((ref) async => const <NetWorthPointOut>[]),
        evolutionProvider.overrideWith((ref) async => evolution()),
        milestonesProvider.overrideWith((ref) async => milestones()),
        assetClassesProvider.overrideWith((ref) async => const <AssetClassOut>[]),
        assetsProvider.overrideWith((ref) async => const <AssetOut>[]),
        performanceProvider.overrideWith((ref, s) async => PerformanceOut(
              first: DateTime(2024, 10, 4), days: 728, value: '12164.25', contributed: '11160.00', gain: '1004.25',
              twr: '0.0912', twrAnnual: '0.0461', ytd: '0.0533', xirr: '0.0478', maxDrawdown: '-0.1124',
              volatility: '0.1012', best: month(5, '0.0412'), worst: month(3, '-0.0377'), positiveMonths: 15,
              negativeMonths: 8, months: [month(3, '-0.0377'), month(4, '0.0100'), month(5, '0.0412')], series: const [],
              beforeUntil: DateTime(2026, 9, 30), beforeContributed: '1500.00', beforeValue: '1980.00')),
      ],
      child: const MaterialApp(home: PatrimonioPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('networth-total')), findsOneWidget);
    // Sin céntimos a partir de 10.000 €; sin deudas, el centro del donut es el mismo neto
    expect(find.descendant(of: find.byKey(const Key('networth-total')), matching: find.text('13.164 €')), findsOneWidget);
    expect(find.text('13.164 €'), findsNWidgets(2));
    // Variación frente al cierre del mes anterior (27 sep: 12.900 €) y "si vendieras hoy" corto con ⓘ
    expect(find.text('+264,25 €'), findsOneWidget);
    expect(find.text('frente al cierre de sep 26'), findsOneWidget);
    expect(find.text('Si vendieras hoy: '), findsOneWidget);
    expect(find.text('12.973 €'), findsOneWidget);
    expect(find.text('Fuente oficial'), findsOneWidget);
    // Qué tienes (donut) y lo que debes, aparte
    expect(find.text('Fondo mundial'), findsOneWidget);
    expect(find.textContaining('Nada pendiente'), findsOneWidget);
    // Hitos: alcanzados con su fecha y el siguiente con la proyección (y su ⓘ)
    expect(find.textContaining('Ya los superabas al empezar la serie (jul 26)'), findsOneWidget);
    expect(find.text('ago 26'), findsOneWidget);
    expect(find.text('al ritmo actual ~ene 28'), findsOneWidget);
    await tester.tap(find.byKey(const Key('edit-milestones')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('threshold-12000')), findsOneWidget);
    await tester.enterText(find.descendant(of: find.byKey(const Key('new-threshold')), matching: find.byType(EditableText)), '50000');
    await tester.tap(find.text('Añadir'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('threshold-50000')), findsOneWidget);
    // La rentabilidad completa está en Inversiones → Rendimiento; aquí, un resumen con enlace
    expect(find.byKey(const Key('perf-summary')), findsOneWidget);
    expect(find.textContaining('acumulada +9,12 %'), findsOneWidget);
    expect(find.text('TWR acumulada'), findsNothing);
  });

  testWidgets('evolución: cuatro vistas, la línea del neto y el aviso de un punto por ciclo', (tester) async {
    tester.view.physicalSize = const Size(420, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [evolutionProvider.overrideWith((ref) async => evolution())],
      child: const MaterialApp(home: EvolutionPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Patrimonio neto'), findsWidgets); // leyenda de la vista Total
    expect(find.textContaining('un punto por ciclo'), findsOneWidget);
    expect(find.textContaining('hasta ago 26, un punto por ciclo'), findsOneWidget);
    for (final (view, legend) in [('Por componente', 'Banco'), ('Tu dinero vs mercado', 'Aportado'), ('Reparto %', 'Fondo mundial')]) {
      await tester.tap(find.text(view));
      await tester.pumpAndSettle();
      expect(find.text(legend), findsWidgets, reason: view);
    }
  });

  testWidgets('rendimiento: KPIs, mejor y peor mes y antes del seguimiento', (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        networthProvider.overrideWith((ref) async => NetWorthOut(
              total: '13164.25', accounts: [AccountBalanceOut(id: 'a', name: 'Banco', kind: 'gastos', balance: '1000.00')],
              investments: '12164.25', pending: '0.00', byType: const {'fondo': '10916.70'}, receivable: '0.00',
              debts: '0.00', installments: '0.00', unrealizedGain: '1004.25', taxIfSold: '190.81',
              afterTax: '12973.44', taxYear: 2026, taxSource: 'https://www.boe.es/x')),
        networthHistoryProvider.overrideWith((ref) async => const <NetWorthPointOut>[]),
        assetClassesProvider.overrideWith((ref) async => const <AssetClassOut>[]),
        assetsProvider.overrideWith((ref) async => const <AssetOut>[]),
        performanceProvider.overrideWith((ref, s) async => PerformanceOut(
              first: DateTime(2024, 10, 4), days: 728, value: '12164.25', contributed: '11160.00', gain: '1004.25',
              twr: '0.0912', twrAnnual: '0.0461', ytd: '0.0533', xirr: '0.0478', maxDrawdown: '-0.1124',
              volatility: '0.1012', best: month(5, '0.0412'), worst: month(3, '-0.0377'), positiveMonths: 15,
              negativeMonths: 8, months: [month(3, '-0.0377'), month(4, '0.0100'), month(5, '0.0412')], series: const [],
              beforeUntil: DateTime(2026, 9, 30), beforeContributed: '1500.00', beforeValue: '1980.00')),
      ],
      child: const MaterialApp(home: PerformancePage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('+9,12 %'), findsOneWidget);
    expect(find.text('+4,78 %'), findsOneWidget); // XIRR
    expect(find.text('−11,24 %'), findsOneWidget); // máx. caída
    expect(find.text('may 2026 (+4,12 %)'), findsOneWidget);
    expect(find.text('15 / 8'), findsOneWidget);
    // Inicio del seguimiento: lo anterior, resumido en un bloque
    expect(find.textContaining('Seguimiento desde el'), findsOneWidget);
    expect(find.textContaining('Antes del seguimiento'), findsOneWidget);
    expect(find.textContaining('ganancia +480,00 €'), findsOneWidget);
  });
}

AssetOut _asset(String id, String name, String cls) => AssetOut(
      id: id, name: name, type: AssetOutTypeEnum.fondo, assetClassId: cls, platformId: null, isin: null,
      ticker: null, coingeckoId: null, currency: 'EUR', priceProvider: AssetOutPriceProviderEnum.manual,
      priceRef: null, unitsDecimals: null, sector: null, country: null, watchlist: false, archived: false,
      notes: null,
    );

TxOut _tx(String asset) => TxOut(
      id: 't-$asset', assetId: asset, kind: TxOutKindEnum.compra, status: TxOutStatusEnum.liquidada,
      tradeDate: DateTime(2026, 9, 1), settleDate: null, amountEur: '100.00', units: '1', price: '100',
      avgCost: null, fee: '0', pairId: null, movementId: null, notes: null,
    );

void scopeTests() {
  testWidgets('rendimiento: el selector solo ofrece lo que tiene historial o posición', (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        assetClassesProvider.overrideWith((ref) async => [
              AssetClassOut(id: 'f', name: 'Fondos', defaultTolerancePp: '1', sort: 0),
              AssetClassOut(id: 'a', name: 'Acciones', defaultTolerancePp: '1', sort: 1),
            ]),
        assetsProvider.overrideWith((ref) async => [_asset('w', 'Fondo mundial', 'f'), _asset('ez', 'Energía Demo', 'a')]),
        allTxProvider.overrideWith((ref) async => [_tx('w')]),
        portfolioProvider.overrideWith((ref) async => PortfolioOut(
              value: '0', cost: '0', pnl: '0', pnlPct: '0', pending: '0', stale: 0, classes: const [],
              unclassified: const [], emergency: null,
            )),
        performanceProvider.overrideWith((ref, s) async => PerformanceOut(
              first: null, days: 0, value: '0', contributed: '0', gain: '0', twr: null, twrAnnual: null, ytd: null,
              xirr: null, maxDrawdown: null, volatility: null, best: null, worst: null, positiveMonths: 0,
              negativeMonths: 0, months: const [], series: const [], beforeUntil: null, beforeContributed: null,
              beforeValue: null)),
      ],
      child: const MaterialApp(home: PerformancePage()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('perf-scope')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('option-Fondo mundial')), findsOneWidget);
    expect(find.byKey(const Key('option-Fondos')), findsOneWidget);
    expect(find.byKey(const Key('option-Energía Demo')), findsNothing); // ni operaciones ni posición
    expect(find.byKey(const Key('option-Acciones')), findsNothing); // categoría sin nada que medir
  });
}
