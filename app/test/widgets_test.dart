import 'package:faro/core/token_store.dart';
import 'package:faro/core/api.dart';
import 'package:faro/core/widgets.dart';
import 'package:faro/features/auth/auth_controller.dart';
import 'package:faro/features/auth/login_page.dart';
import 'package:faro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Controlador falso: fija el estado sin red.
class FakeAuth extends AuthController {
  FakeAuth(this.initial);
  final AuthState initial;
  @override
  AuthState build() => initial;
}

Future<void> pumpApp(WidgetTester tester, AuthState state, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(state)),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ],
    child: const FaroApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_ES'));

  testWidgets('sin sesión muestra login y valida campos vacíos', (tester) async {
    await pumpApp(tester, const AuthLoggedOut(), const Size(400, 800));
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Introduce un email válido'), findsOneWidget);
    expect(find.text('Introduce la contraseña'), findsOneWidget);
  });

  testWidgets('el mensaje de sesión caducada se muestra en login', (tester) async {
    await pumpApp(tester, const AuthLoggedOut(message: 'La sesión ha caducado.'),
        const Size(400, 800));
    expect(find.text('La sesión ha caducado.'), findsOneWidget);
  });

  testWidgets('Android con sesión guardada pide desbloqueo', (tester) async {
    await pumpApp(tester, const AuthLocked(), const Size(400, 800));
    expect(find.text('Fanal está bloqueado'), findsOneWidget);
  });

  testWidgets('FieldRow: en fila si caben, uno debajo de otro si no (las etiquetas no se cortan)', (tester) async {
    Future<void> at(double width) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: const FieldRow(children: [
                  TextField(decoration: InputDecoration(labelText: 'Día de cobro habitual')),
                  TextField(decoration: InputDecoration(labelText: 'Nómina habitual')),
                ]),
              ),
            ),
          ),
        ));
    await at(600);
    expect(tester.getTopLeft(find.text('Nómina habitual')).dy, tester.getTopLeft(find.text('Día de cobro habitual')).dy);
    await at(320);
    expect(tester.getTopLeft(find.text('Nómina habitual')).dy,
        greaterThan(tester.getTopLeft(find.text('Día de cobro habitual')).dy));
  });
}
