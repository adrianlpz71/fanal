import 'package:faro/features/gastos/cycle_page.dart';
import 'package:faro/features/gastos/data.dart';
import 'package:faro/features/gastos/months_page.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

MovementOut mv(String id, String concept, String amount,
        {bool planned = false, MovementOutKindEnum kind = MovementOutKindEnum.gasto, String source = 'manual'}) =>
    MovementOut(
      id: id, accountId: 'a', cycleId: 'c', date: null, dueDate: planned ? DateTime(2026, 10, 1) : null,
      kind: kind, status: planned ? MovementOutStatusEnum.planned : MovementOutStatusEnum.posted,
      concept: concept, amount: amount, expression: null, lines: const [], categoryId: 'cat-food',
      source_: source, sourceRef: null, notes: null, shares: const [],
    );

CycleDetailOut cycle({DateTime? start}) => CycleDetailOut(
      id: 'c', label: 'Octubre 26', status: CycleDetailOutStatusEnum.open,
      startDate: start ?? DateTime(2026, 9, 28), endDate: null, carriedExpected: null, discrepancy: null,
      summary: CycleSummaryOut(
        carried: '412.00', payroll: '1950.00', opening: '2362.00', availableNow: '1234.56',
        expectedEnd: '726.00', netMovements: '-1636.00', pendingTotal: '-67.00', fixedSpend: '412.00',
        variableSpend: '790.00', installments: '95.00', savings: '200.00', savingsRate: '0.1103',
        daysToPayday: 26, perDay: '28.26',
      ),
      movements: [
        mv('1', 'Nómina', '1950.00', kind: MovementOutKindEnum.nomina),
        mv('2', 'Hamburguesa', '-12.50'),
        mv('3', 'Fibra', '-9.00', planned: true, source: 'recurring'),
      ],
    );

Future<void> pump(WidgetTester tester, {Widget? home, bool undoAvailable = false, DateTime? start}) async {
  tester.view.physicalSize = const Size(420, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(), // un contenedor nuevo en cada pump (si no, se quedan los overrides del anterior)
    overrides: [
      gastosSettingsProvider.overrideWith((ref) async => GastosSettingsOut(
            configured: true, paydayDay: 27, usualPayroll: '1950.00', mainAccountId: 'a',
            refugioAccountId: null, emergencyTarget: null, monthlyRefugio: null, forecastMonths: 6)),
      currentCycleProvider.overrideWith((ref) async => cycle(start: start)),
      paydayUndoProvider.overrideWith((ref) async => PaydayUndoOut(available: undoAvailable, reason: null)),
      categoriesProvider.overrideWith((ref) async => [
            CategoryOut(id: 'cat-food', parentId: null, name: 'Comida fuera', kind: 'gasto',
                icon: 'restaurant', color: '#FF7043', fixed: false, archived: false),
          ]),
      recurringProvider.overrideWith((ref) async => const <RecurringOut>[]),
      accountsProvider.overrideWith((ref) async => [
            AccountOut(id: 'a', kind: AccountOutKindEnum.gastos, name: 'Cuenta de gastos', bank: '',
                balance: '800.00', balanceWithPlanned: '700.00', archived: false),
            AccountOut(id: 's', kind: AccountOutKindEnum.ahorro, name: 'Cuenta remunerada', bank: '',
                balance: '3000.00', balanceWithPlanned: '3000.00', archived: false),
          ]),
      monthsAheadProvider.overrideWith((ref) async => ForecastOut(months: [nov()], liveInstallmentDebt: '0.00')),
      cyclesProvider.overrideWith((ref) async {
        final c = cycle();
        return [
          CycleOut(id: c.id, label: c.label, status: CycleOutStatusEnum.open, startDate: c.startDate,
              endDate: null, carriedExpected: null, discrepancy: null, summary: c.summary),
        ];
      }),
      cycleDetailProvider.overrideWith((ref, id) async => cycle()),
      monthProvider.overrideWith((ref, ym) async => novDetail()),
    ],
    child: MaterialApp(home: home ?? const CyclePage()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));
  monthTests();

  testWidgets('«He cobrado» se puede deshacer los primeros días, con confirmación', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('undo-payday')), findsNothing); // no hay cobro que deshacer
    final now = DateTime.now();
    await pump(tester, undoAvailable: true, start: DateTime(now.year, now.month, now.day));
    expect(find.textContaining('Ciclo abierto con «He cobrado»'), findsOneWidget);
    await tester.tap(find.byKey(const Key('undo-payday')));
    await tester.pumpAndSettle();
    expect(find.text('¿Deshacer «He cobrado»?'), findsOneWidget);
    expect(find.textContaining('lo que hayas apuntado en el ciclo nuevo pasa al reabierto'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    // Pasada una semana ya no estorba (sigue disponible por la API mientras el ciclo esté abierto)
    await pump(tester, undoAvailable: true, start: DateTime(now.year, now.month, now.day - 10));
    expect(find.byKey(const Key('undo-payday')), findsNothing);
  });

  testWidgets('cabecera del ciclo con formato es-ES y secciones', (tester) async {
    await pump(tester);
    expect(find.text('Octubre 26'), findsOneWidget);
    expect(find.text('1.234,56 €'), findsOneWidget); // disponible: separador de miles
    expect(find.text('726,00 €'), findsOneWidget);
    expect(find.textContaining('26 días hasta la nómina'), findsOneWidget);
    expect(find.textContaining('28,26 €/día'), findsOneWidget);
    expect(find.text('Ahorro 200,00 € (11 %)'), findsOneWidget);
    expect(find.text('PENDIENTES (1)'), findsOneWidget);
    expect(find.text('CARGADOS (2)'), findsOneWidget); // la nómina va en su fecha, como el resto
    expect(find.text('−12,50 €'), findsOneWidget);
  });

  testWidgets('fecha de cargo: botón visible para marcar cargado, grupo "Sin fecha" y categorizar', (tester) async {
    await pump(tester);
    // El previsto lleva su fecha prevista y un botón visible (no solo deslizar)
    expect(find.byKey(const Key('post-3')), findsOneWidget);
    expect(find.textContaining('1 oct ·'), findsOneWidget); // en el móvil, la fecha va delante del subtítulo
    // Los cargados sin fecha (p. ej. del Excel) van en su grupo, con acción para ponérsela
    expect(find.text('SIN FECHA (2)'), findsOneWidget);
    expect(find.byKey(const Key('date-all')), findsOneWidget);
    expect(find.textContaining('sin fecha de cargo'), findsWidgets);
  });

  testWidgets('el desglose filtra la lista y la búsqueda también', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('summary-inicial')));
    await tester.pumpAndSettle();
    expect(find.text('Hamburguesa'), findsNothing); // Inicial = nómina e ingresos
    expect(find.text('Nómina'), findsOneWidget);
    await tester.tap(find.byKey(const Key('summary-inicial')));
    await tester.pumpAndSettle();
    // En el móvil, la búsqueda y los filtros van plegados detrás de la lupa
    expect(find.byKey(const Key('cycle-search')), findsNothing);
    await tester.tap(find.byKey(const Key('toggle-filters')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cycle-search')), 'hambur');
    await tester.pumpAndSettle();
    expect(find.text('Hamburguesa'), findsOneWidget);
    expect(find.text('Fibra'), findsNothing);
  });

  testWidgets('el teclado construye el importe y el botón Añadir existe', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('add-movement')));
    await tester.pumpAndSettle();
    for (final k in ['1', '2', ',', '5']) {
      await tester.tap(find.byKey(Key('key-$k')));
    }
    await tester.pump();
    expect(find.text('−12,5 €'), findsOneWidget);
    await tester.tap(find.byKey(const Key('key-⌫')));
    await tester.pump();
    expect(find.text('−12, €'), findsOneWidget);
    expect(find.byKey(const Key('save-movement')), findsOneWidget);
    expect(find.byKey(const Key('delete-movement')), findsNothing); // solo al editar
  });

  testWidgets('al editar un movimiento hay botón Eliminar', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Hamburguesa'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-movement')), findsOneWidget);
    expect(find.text('Duplicar'), findsOneWidget);
  });
}

ForecastMonthOut nov() => ForecastMonthOut(
      label: 'Noviembre 26', ym: '2026-11', start: DateTime(2026, 10, 27), end: DateTime(2026, 11, 26),
      payroll: '1845.00', recurring: '-13.99', installments: '0.00', other: '-80.00', free: '1751.01',
      cumulative: '2486.01',
    );

MonthOut novDetail() {
  final n = nov();
  return MonthOut(
    label: n.label, ym: n.ym, start: n.start, end: n.end, payroll: n.payroll, recurring: n.recurring,
    installments: n.installments, other: n.other, free: n.free, cumulative: n.cumulative,
    items: [
      MonthItemOut(kind: MonthItemOutKindEnum.recurrente, date: DateTime(2026, 10, 28), concept: 'Netflix',
          amount: '-13.99', categoryId: 'cat-food', source_: 'recurring', movement: null, templateId: 't1'),
      MonthItemOut(kind: MonthItemOutKindEnum.movimiento, date: DateTime(2026, 11, 5), concept: 'Regalo',
          amount: '-80.00', categoryId: 'cat-food', source_: 'manual',
          movement: mv('9', 'Regalo', '-80.00', planned: true), templateId: null),
    ],
  );
}

void monthTests() {
  testWidgets('traspaso a la cuenta de ahorro: se elige la cuenta y no es gasto', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('add-movement')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transfer-account')), findsNothing);
    await tester.tap(find.text('Traspaso'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transfer-account')));
    await tester.pumpAndSettle();
    // Solo tus otras cuentas: la de gastos no sale como destino
    expect(find.text('Cuenta de gastos'), findsNothing);
    await tester.tap(find.text('Cuenta remunerada').last);
    await tester.pumpAndSettle();
    expect(find.text('A Cuenta remunerada'), findsOneWidget); // concepto propuesto
    expect(find.textContaining('Saldo ahora: 3.000,00 €'), findsOneWidget);
    await tester.tap(find.text('Traer dinero de esa cuenta a la de gastos'));
    await tester.pumpAndSettle();
    expect(find.text('Desde la cuenta'), findsOneWidget);
  });

  testWidgets('al añadir se puede elegir un mes futuro (queda como pendiente)', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('add-movement')));
    await tester.pumpAndSettle();
    expect(find.text('Octubre 26'), findsWidgets);
    await tester.tap(find.byKey(const Key('month-chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Noviembre 26'));
    await tester.pumpAndSettle();
    expect(find.text('Noviembre 26'), findsOneWidget);
    final pending = tester.widget<SwitchListTile>(
        find.descendant(of: find.byKey(const Key('planned-switch')), matching: find.byType(SwitchListTile)));
    expect(pending.value, isTrue); // en un mes futuro siempre queda como previsto
    expect(pending.onChanged, isNull);
    expect(find.text('Fecha prevista'), findsOneWidget);
    expect(find.text('Al empezar el mes'), findsOneWidget);
  });

  testWidgets('Meses: navegar al mes siguiente y ver lo previsto', (tester) async {
    await pump(tester, home: const MonthsPage());
    expect(find.text('Octubre 26 · actual'), findsOneWidget);
    expect(find.text('Hamburguesa'), findsOneWidget);
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Netflix'), findsOneWidget); // proyección del recurrente
    expect(find.text('Regalo'), findsOneWidget); // gasto planificado
    expect(find.text('Añadir a Noviembre 26'), findsOneWidget);
    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();
    expect(find.text('Saltar este mes'), findsOneWidget);
    expect(find.text('Dar de baja desde Noviembre 26'), findsOneWidget);
  });
}
