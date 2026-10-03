import 'package:faro/features/inversiones/data.dart';
import 'package:faro/features/inversiones/targets_page.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

AssetOut asset(String id, String name, String cls) => AssetOut(
      id: id, name: name, type: AssetOutTypeEnum.fondo, assetClassId: cls, platformId: null, isin: null,
      ticker: null, coingeckoId: null, currency: 'EUR', priceProvider: AssetOutPriceProviderEnum.manual,
      priceRef: null, unitsDecimals: null, sector: null, country: null, watchlist: false, archived: false,
      notes: null,
    );

PositionOut pos(AssetOut a, String units, String value, {String? target}) => PositionOut(
      asset: a, units: units, avgCost: '10', cost: value, price: '10', priceDate: DateTime(2026, 9, 30),
      priceSource: 'manual', stale: false, value: value, pnl: '0', pnlPct: '0', pending: '0.00',
      innerWeight: '0.5', innerTarget: target, innerStatus: null,
    );

ClassOut cls(String id, String name, String value, String? target, List<PositionOut> positions) => ClassOut(
      assetClass: AssetClassOut(id: id, name: name, defaultTolerancePp: '1', sort: 0), value: value,
      pending: '0.00', weight: '0', target: target, min: null, max: null, tolerancePp: '1', status: null,
      positions: positions,
    );

final world = asset('w', 'Fondo mundial', 'f');
final globalFund = asset('fi', 'Fondo indexado global', 'f');
final energia = asset('ez', 'Energía Demo', 'a');
final construcciones = asset('oh', 'Construcciones Demo', 'a');

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  test('Inversiones: fuera las categorías a 0 % sin dinero y los activos sin posición ni objetivo', () {
    final fondos = cls('f', 'Fondos', '1000', '0.9', [pos(world, '10', '1000', target: '1'), pos(globalFund, '0', '0')]);
    final acciones = cls('a', 'Acciones', '0', '0', [pos(energia, '0', '0', target: '0.45')]);
    expect(showClass(fondos), isTrue);
    expect(showClass(acciones), isFalse); // objetivo 0 % y sin posiciones
    expect(showPosition(fondos, fondos.positions[0]), isTrue);
    expect(showPosition(fondos, fondos.positions[1]), isFalse); // sin posición y sin objetivo
    expect(showPosition(acciones, acciones.positions[0]), isFalse); // objetivo dentro de una categoría a 0 %
    // Con objetivo en la categoría, un activo sin posición pero con objetivo es una compra prevista
    final aMedias = cls('a', 'Acciones', '0', '0.05', [pos(energia, '0', '0', target: '0.45')]);
    expect(showClass(aMedias), isTrue);
    expect(showPosition(aMedias, aMedias.positions[0]), isTrue);
  });

  testWidgets('Objetivos: reparto con menú para quitar o archivar, sin campos cortados', (tester) async {
    tester.view.physicalSize = const Size(412, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final classes = [
      AssetClassOut(id: 'f', name: 'Fondos', defaultTolerancePp: '1', sort: 0),
      AssetClassOut(id: 'a', name: 'Acciones', defaultTolerancePp: '2', sort: 1),
    ];
    final today = DateTime(2026, 10, 1);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        assetClassesProvider.overrideWith((ref) async => classes),
        assetsProvider.overrideWith((ref) async => [world, globalFund, energia, construcciones]),
        targetsProvider.overrideWith((ref) async => TargetsOut(
              macro: [
                MacroTargetOut(assetClassId: 'f', target: '1', min: '0.9', max: '1', tolerancePp: '1', validFrom: today),
                MacroTargetOut(assetClassId: 'a', target: '0', min: '0', max: '0.05', tolerancePp: '2', validFrom: today),
              ],
              assets: [
                AssetTargetOut(assetId: 'w', target: '1', validFrom: today),
                AssetTargetOut(assetId: 'ez', target: '0.45', validFrom: today),
                AssetTargetOut(assetId: 'oh', target: '0.55', validFrom: today),
              ],
            )),
        portfolioProvider.overrideWith((ref) async => PortfolioOut(
              value: '1000', cost: '1000', pnl: '0', pnlPct: '0', pending: '0', stale: 0,
              classes: [cls('f', 'Fondos', '1000', '1', [pos(world, '10', '1000', target: '1')])],
              unclassified: const [], emergency: null,
            )),
      ],
      child: const MaterialApp(home: TargetsPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Objetivo'), findsWidgets); // etiquetas completas, sin "Obj…"
    expect(find.text('Tolerancia'), findsNWidgets(2));
    // El fondo global (sin posición ni objetivo) no está en el reparto; se puede añadir con "Añadir activo"
    expect(find.byKey(const Key('target-fi')), findsNothing);
    expect(find.byKey(const Key('target-ez')), findsOneWidget);
    expect(find.text('Suma 100 %'), findsNWidgets(2));

    // Quitar Energía Demo y archivarlo: deja de estar y la suma de Acciones cambia
    await tester.tap(find.descendant(of: find.byKey(const Key('target-ez')), matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitar y archivar el activo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('target-ez')), findsNothing);
    expect(find.textContaining('Suma 55 %'), findsOneWidget);
    expect(find.textContaining('Al guardar se archivarán: Energía Demo'), findsOneWidget);
  });
}
