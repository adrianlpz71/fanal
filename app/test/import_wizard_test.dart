import 'package:faro/core/widgets.dart';
import 'package:faro/features/gastos/data.dart' show importBatchesProvider;
import 'package:faro/features/imports/column_mapper.dart';
import 'package:faro/features/imports/import_wizard.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

BatchOut batch(String id, String name, {String kind = 'platform', String status = 'committed'}) => BatchOut(
      id: id, kind: kind, filename: name, status: status, createdAt: DateTime(2026, 10, 2),
      counts: const {'new': 30, 'duplicate': 4}, fileBalance: null,
    );

Future<void> pump(WidgetTester tester, {String? source, int? step, List<BatchOut> batches = const []}) async {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(),
    overrides: [
      importBatchesProvider.overrideWith((ref) async => batches),
      bankProfilesProvider.overrideWith((ref) async => const <BankProfileOut>[]),
      brokerProfilesProvider.overrideWith((ref) async => const <BankProfileOut>[]),
    ],
    child: MaterialApp(home: ImportWizardPage(source: source, step: step)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  testWidgets('paso 1: cinco plataformas y el historial con "Deshacer" (con confirmación)', (tester) async {
    await pump(tester, batches: [batch('b1', 'ordenes.csv'), batch('b2', 'extracto.xlsx', kind: 'bank', status: 'undone')]);
    for (final s in ['myinvestor', 'neverless', 'trade-republic', 'banco', 'otro']) {
      expect(find.byKey(Key('source-$s')), findsOneWidget);
    }
    // En ancho, los cinco pasos con nombre; con el texto grande no caben y sale "Paso 1 de 5"
    if (tester.platformDispatcher.textScaleFactor == 1) {
      expect(find.byKey(const Key('step-0')), findsOneWidget);
    } else {
      expect(find.textContaining('Paso 1 de 5'), findsOneWidget);
    }
    expect(find.text('ordenes.csv'), findsOneWidget);
    expect(find.textContaining('Inversiones · 34 filas · 30 nuevas'), findsOneWidget);
    expect(find.textContaining('deshecha'), findsOneWidget);
    expect(find.byKey(const Key('undo-b2')), findsNothing); // ya deshecha
    await tester.tap(find.byKey(const Key('undo-b1')));
    await tester.pumpAndSettle();
    expect(find.text('¿Deshacer la importación de «ordenes.csv»?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('paso 2: el tutorial de la plataforma y luego la zona para soltar el fichero', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('source-myinvestor')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Consulta de operaciones', findRichText: true), findsOneWidget);
    expect(find.text('Formatos: CSV'), findsOneWidget);
    await tester.tap(find.byKey(const Key('howto-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('drop-zone')), findsOneWidget);
    expect(find.text('Arrastra aquí el fichero'), findsOneWidget);
    expect(find.byKey(const Key('pick-file')), findsOneWidget);
  });

  testWidgets('enlace directo: ?fuente=banco&paso=2 abre el tutorial del banco', (tester) async {
    await pump(tester, source: 'banco', step: 2);
    expect(find.textContaining('Cómo descargar los movimientos de tu banco', findRichText: true), findsOneWidget);
    expect(find.text('Formatos: CSV, XLSX, TXT'), findsOneWidget);
  });

  testWidgets('markdown sencillo: títulos, listas y negrita', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MarkdownLite('# Título\n\n1. Uno **fuerte**\n- Punto\n\nTexto normal')),
    ));
    expect(find.text('Título'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
    expect(find.textContaining('Uno fuerte', findRichText: true), findsOneWidget);
    expect(find.textContaining('Texto normal', findRichText: true), findsOneWidget);
  });
}
