import 'package:faro/features/inversiones/assets_page.dart';
import 'package:faro/features/inversiones/contribution_page.dart';
import 'package:faro/features/inversiones/contributions_history_page.dart';
import 'package:faro/features/inversiones/data.dart';
import 'package:faro/features/inversiones/inv_page.dart';
import 'package:faro/features/inversiones/tx_sheet.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

AssetOut asset(String id, String name, AssetOutTypeEnum type, String cls) => AssetOut(
      id: id, name: name, type: type, assetClassId: cls, platformId: null, isin: null, ticker: null,
      coingeckoId: null, currency: 'EUR', priceProvider: AssetOutPriceProviderEnum.manual, priceRef: null,
      unitsDecimals: null, sector: null, country: null, watchlist: false, archived: false, notes: null,
    );

PositionOut pos(AssetOut a, String units, String value, String pnlPct, PositionOutInnerStatusEnum st) => PositionOut(
      asset: a, units: units, avgCost: '11.20', cost: '1064.00', price: '15.1', priceDate: DateTime(2026, 9, 30),
      priceSource: 'ft', stale: false, value: value, pnl: '370.50', pnlPct: pnlPct, pending: '0.00',
      innerWeight: '0.7363', innerTarget: '0.7', innerStatus: st,
    );

PortfolioOut portfolio() {
  final fondos = AssetClassOut(id: 'f', name: 'Fondos', defaultTolerancePp: '1', sort: 0);
  final msci = asset('m', 'MSCI World', AssetOutTypeEnum.fondo, 'f');
  return PortfolioOut(
    value: '2126.98', cost: '1610.79', pnl: '516.18', pnlPct: '0.3205', pending: '0.00', stale: 1,
    classes: [
      ClassOut(
        assetClass: fondos, value: '1948.23', pending: '0.00', weight: '0.9160', target: '0.9', min: '0.7',
        max: '0.95', tolerancePp: '1', status: ClassOutStatusEnum.ok,
        positions: [pos(msci, '95.00', '1434.50', '0.3482', PositionOutInnerStatusEnum.noComprar)],
      ),
    ],
    unclassified: const [],
    emergency: EmergencyOut(target: '4000.00', current: '700.00', coverage: '0.175', missing: '3300.00',
        suggestedMonthly: '3300.00'),
  );
}

Future<void> pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 4000); // alto de sobra: la lista entera, también con texto grande
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      invSettingsProvider.overrideWith((ref) async => InvSettingsOut(configured: true, minOperation: '0.00', monthlyContribution: null, trackStart: null)),
      portfolioProvider.overrideWith((ref) async => portfolio()),
      targetsProvider.overrideWith((ref) async => TargetsOut(macro: const [], assets: const [])),
      pendingTxProvider.overrideWith((ref) async => const <TxOut>[]),
      assetsProvider.overrideWith((ref) async => const <AssetOut>[]),
    ],
    child: const MaterialApp(home: InvestmentsPage()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));
  txTests();
  contributionTests();

  testWidgets('aportar: opción de redondear las órdenes (1, 5 o 10 €)', (tester) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        invSettingsProvider.overrideWith((ref) async =>
            InvSettingsOut(configured: true, minOperation: '0.00', monthlyContribution: '300.00', trackStart: null)),
        assetClassesProvider.overrideWith((ref) async => const <AssetClassOut>[]),
      ],
      child: const MaterialApp(home: ContributionPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Redondear las órdenes'), findsOneWidget);
    expect(find.byKey(const Key('round-unit')), findsNothing);
    await tester.tap(find.text('Redondear las órdenes'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('round-unit')), findsOneWidget);
    expect(find.text('5 €'), findsOneWidget);
  });

  test('porcentajes en es-ES', () {
    expect(pct('0.91615'), '91,62 %');
    expect(pct('0.3205', plus: true), '+32,05 %');
    expect(fractionFromPct('70'), '0.7');
    expect(fractionFromPct('12,5'), '0.125');
  });

  testWidgets('panel: valor, P/L, emergencia, estado y aviso de precio viejo', (tester) async {
    await pump(tester);
    expect(find.text('2.126,98 €'), findsOneWidget);
    expect(find.text('+516,18 €'), findsOneWidget);
    expect(find.text('+32,05 %'), findsOneWidget);
    expect(find.text('Fondo de emergencia'), findsOneWidget);
    expect(find.textContaining('faltan 3.300,00 €'), findsOneWidget);
    // Vocabulario claro: describe dónde está cada cosa, nunca dice "comprar"
    expect(find.text('Por encima del objetivo'), findsOneWidget);
    expect(find.text('Dentro del rango'), findsOneWidget);
    expect(find.text('No comprar'), findsNothing);
    expect(find.text('1 precio sin actualizar'), findsOneWidget);
    expect(find.text('Define los objetivos de tu cartera'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('No es una recomendación'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('No es una recomendación'), findsOneWidget);
  });
}

/// Hoja "Nueva operación" con los activos del panel.
Future<void> pumpTx(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final msci = asset('m', 'MSCI World', AssetOutTypeEnum.fondo, 'f');
  await tester.pumpWidget(ProviderScope(
    overrides: [
      portfolioProvider.overrideWith((ref) async => portfolio()),
      assetsProvider.overrideWith((ref) async => [msci]),
      assetClassesProvider.overrideWith(
          (ref) async => [AssetClassOut(id: 'f', name: 'Fondos', defaultTolerancePp: '1', sort: 0)]),
      platformsProvider.overrideWith((ref) async => const <PlatformOut>[]),
    ],
    child: MaterialApp(
      home: Consumer(
        builder: (context, ref, _) => Scaffold(
          body: TextButton(onPressed: () => showTxSheet(context, ref, assetId: 'm'), child: const Text('abrir')),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void txTests() {
  testWidgets('nueva operación: el tipo primero y solo los campos de ese tipo, con vista previa', (tester) async {
    await pumpTx(tester, const Size(1200, 1000));
    expect(find.byType(Dialog), findsOneWidget); // en pantallas anchas, diálogo
    expect(find.text('MSCI World'), findsOneWidget);
    expect(find.byKey(const Key('tx-date')), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing); // la fecha es un campo, no un chip
    await tester.enterText(find.byKey(const Key('tx-amount')), '300');
    await tester.enterText(find.byKey(const Key('tx-price')), '25');
    await tester.pumpAndSettle();
    expect(find.textContaining('Equivale a 12,0000 participaciones'), findsOneWidget);
    expect(find.textContaining('Tu PMP pasa de 11,20 €'), findsOneWidget);
    // Posición inicial: participaciones + PMP, sin importe ni comisión
    await tester.tap(find.text('Más tipos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Posición inicial'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx-amount')), findsNothing);
    expect(find.byKey(const Key('tx-fee')), findsNothing);
    expect(find.text('Precio medio de compra (PMP)'), findsOneWidget);
    // Dividendo: solo importe
    await tester.tap(find.text('Dividendo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx-units')), findsNothing);
    expect(find.byKey(const Key('tx-amount')), findsOneWidget);
  });

  testWidgets('nueva operación en el móvil: hoja a pantalla completa con Guardar fijo abajo', (tester) async {
    await pumpTx(tester, const Size(390, 844));
    expect(find.byType(Dialog), findsNothing);
    expect(find.byKey(const Key('save-tx')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

ContributionItemOut citem(String id, DateTime d, String amount,
        {ContributionItemOutTypeEnum type = ContributionItemOutTypeEnum.aportacion,
        ContributionItemOutKindEnum kind = ContributionItemOutKindEnum.inversion, String dest = 'a:m'}) =>
    ContributionItemOut(
      date: d, type: type, kind: kind, destination: dest, destinationLabel: dest == 'a:m' ? 'MSCI World' : 'Ahorro',
      amount: amount, origin: 'manual', status: ContributionItemOutStatusEnum.confirmada, txId: id,
      movementId: null, assetId: dest == 'a:m' ? 'm' : null, accountId: null,
    );

void contributionTests() {
  testWidgets('aportaciones: totales, ritmo, racha, barras por mes y lista; las salidas van aparte', (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        contributionsProvider.overrideWith((ref) async => ContributionsOut(
              thisMonth: '300.00', thisYear: '900.00', total: '1200.00', withdrawn: '50.00', starting: '1000.00',
              pace: '75.00', streak: 3, paceInvesting: '75.00', streakInvesting: 3, trackStart: null,
              destinations: [
                ContributionDestinationOut(key: 'a:m', label: 'MSCI World', kind: ContributionDestinationOutKindEnum.inversion),
                ContributionDestinationOut(key: 'c:s', label: 'Ahorro', kind: ContributionDestinationOutKindEnum.ahorro),
              ],
              months: [
                ContributionMonthOut(year: 2026, month: 9, total: '600.00', byDestination: const {'a:m': '400.00', 'c:s': '200.00'}),
                ContributionMonthOut(year: 2026, month: 10, total: '300.00', byDestination: const {'a:m': '300.00'}),
              ],
              items: [
                citem('1', DateTime(2026, 10, 1), '300.00'),
                citem('2', DateTime(2026, 9, 1), '400.00'),
                citem('3', DateTime(2026, 9, 2), '200.00', kind: ContributionItemOutKindEnum.ahorro, dest: 'c:s'),
                citem('4', DateTime(2026, 9, 15), '50.00', type: ContributionItemOutTypeEnum.retirada),
              ],
            )),
      ],
      child: const MaterialApp(home: ContributionsHistoryPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('3 meses'), findsOneWidget); // racha
    expect(find.textContaining('75,00 €/mes'), findsOneWidget); // ritmo
    expect(find.textContaining('Saldo de partida'), findsOneWidget); // posiciones iniciales, aparte
    expect(find.byKey(const Key('contrib-1')), findsOneWidget);
    expect(find.byKey(const Key('contrib-4')), findsNothing); // una venta no es una aportación
  });

  testWidgets('ficha de activo: acciones con nombre y borrar operación desde el menú de la fila', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final msci = asset('m', 'MSCI World', AssetOutTypeEnum.fondo, 'f');
    final p = pos(msci, '95.00', '1434.50', '0.3482', PositionOutInnerStatusEnum.noComprar);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        assetDetailProvider.overrideWith((ref, id) async => AssetDetailOut(
              position: p, lots: const [], realized: const [], income: '0',
              transactions: [
                TxOut(id: 't1', assetId: 'm', kind: TxOutKindEnum.compra, status: TxOutStatusEnum.liquidada,
                    tradeDate: DateTime(2026, 9, 1), settleDate: null, amountEur: '100.00', units: '7', price: '14.2',
                    avgCost: null, fee: '0', pairId: null, movementId: null, notes: null),
              ],
            )),
      ],
      child: const MaterialApp(home: AssetDetailPage(id: 'm')),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.text('Corregir posición'), findsOneWidget);
    expect(find.byKey(const Key('asset-archive')), findsOneWidget);
    // Borrar, en el menú de la fila (ya no hace falta mantener pulsado) y siempre con confirmación
    await tester.tap(find.byKey(const Key('tx-delete-t1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar operación'));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar la operación?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('ficha de activo: las 5 últimas operaciones y "Ver todas" despliega el resto', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final msci = asset('m', 'MSCI World', AssetOutTypeEnum.fondo, 'f');
    final p = pos(msci, '95.00', '1434.50', '0.3482', PositionOutInnerStatusEnum.noComprar);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        assetDetailProvider.overrideWith((ref, id) async => AssetDetailOut(
              position: p, lots: const [], realized: const [], income: '0',
              transactions: [
                for (var i = 1; i <= 7; i++)
                  TxOut(id: 't$i', assetId: 'm', kind: TxOutKindEnum.compra, status: TxOutStatusEnum.liquidada,
                      tradeDate: DateTime(2026, 9, 10 - i), settleDate: null, amountEur: '100.00', units: '7',
                      price: '14.2', avgCost: null, fee: '0', pairId: null, movementId: null, notes: null),
              ],
            )),
      ],
      child: const MaterialApp(home: AssetDetailPage(id: 'm')),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx-row-t5')), findsOneWidget);
    expect(find.byKey(const Key('tx-row-t6')), findsNothing);
    await tester.tap(find.text('Ver todas (7)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx-row-t7')), findsOneWidget);
  });
}
