import 'package:faro/features/imports/column_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const rows = [
  ['Mi Banco - movimientos'],
  ['Día', 'Texto', 'Euros', 'Resto'],
  ['05/10/2026', 'Supermercado', '-45,20', '954,80'],
];

Future<Map<String, dynamic>?> open(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(500, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Map<String, dynamic>? result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        child: const Text('abrir'),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('mapper-apply')));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('extracto: cabecera detectada, columnas en la vista previa y mapeo devuelto', (tester) async {
    final r = await open(
      tester,
      const ColumnMapperPage(
        title: 'Columnas',
        rows: rows,
        roles: bankRoles,
        initial: {'header_row': 1, 'date': 0, 'concept': [1], 'amount': 2},
      ),
    );
    expect(r, {'header_row': 1, 'date': 0, 'amount': 2, 'concept': [1]});
  });

  testWidgets('sin las columnas obligatorias no se aplica y dice qué falta', (tester) async {
    final r = await open(tester, const ColumnMapperPage(title: 'Columnas', rows: rows, roles: bankRoles));
    expect(r, isNull);
    expect(find.textContaining('Falta: Fecha, Concepto, Importe (o Cargo / Abono)'), findsOneWidget);
    expect(find.text('B · Texto'), findsWidgets); // la vista previa usa la cabecera adivinada
  });

  testWidgets('broker: pide la plataforma y devuelve tipo de clave y de activo', (tester) async {
    final r = await open(
      tester,
      const ColumnMapperPage(
        title: 'Columnas',
        rows: rows,
        roles: brokerRoles,
        broker: true,
        initial: {'header_row': 1, 'date': 0, 'key': 1, 'units': 2, 'amount': 3, 'platform': 'Broker X'},
      ),
    );
    expect(r, containsPair('platform', 'Broker X'));
    expect(r, containsPair('key_type', 'isin'));
    expect(r, containsPair('asset_type', 'fondo'));
    expect(r!.containsKey('concept'), isFalse);
  });
}
