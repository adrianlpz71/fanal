import 'package:faro/core/forms/forms.dart';
import 'package:faro/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _host(Widget child, {double width = 400}) => MaterialApp(
      theme: FaroTheme.light(),
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: Center(child: SizedBox(width: width, child: SingleChildScrollView(child: child)))),
    );

Future<void> _view(WidgetTester tester, Size s) async {
  tester.view.physicalSize = s;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  testWidgets('importe: solo números, coma y signo; etiqueta y € siempre visibles', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(_host(MoneyField(label: 'Importe', controller: c)));
    await tester.enterText(find.byType(TextField), '12a,5€');
    expect(c.text, '12,5');
    expect(find.text('Importe'), findsOneWidget);
    expect(find.text('€'), findsOneWidget);
  });

  testWidgets('fecha: un campo con icono (no un chip) que abre el calendario', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, set) => DateField(
        label: 'Fecha',
        value: picked ?? DateTime(2026, 10, 2),
        onChanged: (d) => set(() => picked = d),
      ),
    )));
    expect(find.text('2 oct 2026'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
    await tester.tap(find.text('2 oct 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.textContaining(RegExp('acept', caseSensitive: false)));
    await tester.pumpAndSettle();
    expect(find.text('15 oct 2026'), findsOneWidget);
  });

  testWidgets('selector: con más de 7 opciones trae buscador; el texto elegido no se corta', (tester) async {
    await _view(tester, const Size(1200, 900));
    String? v;
    final long = 'Fondo indexado mundial de gran capitalización con nombre larguísimo';
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, set) => SelectField<String>(
        label: 'Activo',
        value: v,
        options: [
          for (var i = 0; i < 9; i++) SelectOption('$i', i == 3 ? long : 'Activo $i', subtitle: 'Fondo'),
        ],
        onChanged: (x) => set(() => v = x),
      ),
    )));
    await tester.tap(find.text('Elegir…'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('select-search')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('select-search')), 'mundial');
    await tester.pumpAndSettle();
    expect(find.text('Activo 1'), findsNothing);
    await tester.tap(find.text(long));
    await tester.pumpAndSettle();
    expect(v, '3');
    final text = tester.widget<Text>(find.text(long));
    expect(text.overflow, isNot(TextOverflow.ellipsis));
  });

  testWidgets('segmentos: si los nombres no caben, pasan a chips en varias líneas (sin cortarse)', (tester) async {
    await _view(tester, const Size(1300, 900));
    Widget field(double w) => _host(
          SegmentedField<int>(
            segments: const [Segment(1, 'Compra'), Segment(2, 'Venta'), Segment(3, 'Aportación periódica')],
            value: 1,
            onChanged: (_) {},
          ),
          width: w,
        );
    await tester.pumpWidget(field(1290)); // ancho de sobra también con el texto al 130 %
    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    await tester.pumpWidget(field(200));
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedButton<int>), findsNothing);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
  });

  testWidgets('formulario: diálogo en pantallas anchas y hoja a pantalla completa en el móvil', (tester) async {
    Future<void> open(Size s) async {
      await _view(tester, s);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFormPanel(
                context,
                builder: (_) => FormPanel(
                  title: 'Prueba',
                  actions: FormActions(primaryLabel: 'Guardar', onPrimary: () {}),
                  children: const [Text('campo')],
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    await open(const Size(1200, 900));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byTooltip('Cerrar'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await open(const Size(390, 844));
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });
}
