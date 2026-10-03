import 'package:decimal/decimal.dart';
import 'package:faro/features/patrimonio/tax_report_page.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

IncomeOut reward(int m, int d, String amount) =>
    IncomeOut(source_: 'Bitcoin', date: DateTime(2026, m, d), amount: amount, kind: IncomeOutKindEnum.recompensaCripto);

final income = [
  reward(6, 5, '0.05'), reward(6, 12, '0.06'), reward(7, 1, '0.05'), reward(7, 7, '0.06'), reward(9, 29, '0.07'),
  IncomeOut(source_: 'Cuenta remunerada', date: DateTime(2026, 6, 30), amount: '4.10', kind: IncomeOutKindEnum.interesCuenta),
];

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  test('rendimientos agrupados por origen y tipo, con el desglose por mes', () {
    final g = groupIncome(income);
    expect(g.map((x) => x.source), ['Cuenta remunerada', 'Bitcoin']); // de mayor a menor importe
    final btc = g[1];
    expect(btc.items.length, 5);
    expect(btc.total, Decimal.parse('0.29'));
    expect(btc.first, DateTime(2026, 6, 5));
    expect(btc.last, DateTime(2026, 9, 29));
    expect(btc.byMonth, [
      (2026, 6, 2, Decimal.parse('0.11')),
      (2026, 7, 2, Decimal.parse('0.11')),
      (2026, 9, 1, Decimal.parse('0.07')),
    ]);
  });

  testWidgets('informe: una línea por grupo en vez de un pago por línea', (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        taxReportProvider.overrideWith((ref, year) async => TaxReportOut(
              year: year, sales: const [], gainsTotal: '0.00', transfers: const [], income: income,
              incomeTotal: '4.39', savingsBase: '4.39', yearEnd: const [], foreignTotal: '0.00',
            )),
      ],
      child: const MaterialApp(home: TaxReportPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bitcoin · Recompensas de cripto'), findsOneWidget);
    expect(find.textContaining('5 pagos del 5 jun al 29 sep'), findsOneWidget);
    expect(find.text('0,29 €'), findsOneWidget);
    expect(find.text('jul 2026'), findsNothing); // el desglose está plegado
    await tester.tap(find.text('Bitcoin · Recompensas de cripto'));
    await tester.pumpAndSettle();
    expect(find.text('jul 2026'), findsOneWidget);
    expect(find.text('2 pagos'), findsNWidgets(2));
  });
}
