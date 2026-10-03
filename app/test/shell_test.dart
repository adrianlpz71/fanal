import 'package:faro/core/theme.dart';
import 'package:faro/core/widgets.dart';
import 'package:faro/features/shell/home_shell.dart';
import 'package:faro/features/update/update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Page extends StatelessWidget {
  const _Page(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: FaroAppBar(title: Text(title)), body: Text('body $title'));
}

GoRoute _r(String p) => GoRoute(path: p, builder: (_, _) => _Page(p));

Widget _app(String initial) {
  final router = GoRouter(initialLocation: initial, routes: [
    StatefulShellRoute.indexedStack(
      builder: (c, s, shell) => HomeShell(shell: shell, location: s.uri.path),
      branches: [
        StatefulShellBranch(routes: [
          _r('/gastos'), _r('/gastos/meses'), _r('/gastos/compromisos'), _r('/gastos/fraccionadas'),
          _r('/gastos/gestionar'),
        ]),
        StatefulShellBranch(routes: [_r('/inversiones')]),
        StatefulShellBranch(routes: [_r('/patrimonio')]),
        StatefulShellBranch(routes: [_r('/planes/independencia')]),
        StatefulShellBranch(routes: [_r('/mas')]),
      ],
    ),
  ]);
  return ProviderScope(
    overrides: [
      appVersionProvider.overrideWith((ref) async => const AppVersionInfo(current: '0.9.0', currentBuild: 1)),
    ],
    child: MaterialApp.router(theme: FaroTheme.dark(), routerConfig: router),
  );
}

Future<void> _size(WidgetTester tester, Size s) async {
  tester.view.physicalSize = s;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('móvil: barra inferior con 5 destinos (Tú incluido) y pestañas bajo la barra de la página',
      (tester) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(_app('/gastos'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav-bar')), findsOneWidget);
    expect(find.byKey(const Key('top-bar')), findsNothing);
    expect(find.text('Tú'), findsOneWidget);
    expect(find.text('Este ciclo'), findsOneWidget); // pestañas del apartado
    expect(find.byKey(const Key('privacy-toggle')), findsOneWidget);
    // Una pestaña lleva a su ruta
    await tester.ensureVisible(find.text('Compromisos'));
    await tester.tap(find.text('Compromisos'));
    await tester.pumpAndSettle();
    expect(find.text('body /gastos/compromisos'), findsOneWidget);
    await tester.tap(find.text('Inversiones'));
    await tester.pumpAndSettle();
    expect(find.text('body /inversiones'), findsOneWidget);
  });

  testWidgets('escritorio: barra superior con los apartados, pestañas, tema, privacidad y menú de usuario',
      (tester) async {
    await _size(tester, const Size(1440, 900));
    await tester.pumpWidget(_app('/gastos'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('top-bar')), findsOneWidget);
    expect(find.byKey(const Key('nav-bar')), findsNothing);
    for (final s in ['Gastos', 'Inversiones', 'Patrimonio', 'Planes']) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('Tú'), findsNothing); // en escritorio va en el menú de usuario
    expect(find.byKey(const Key('theme-toggle')), findsOneWidget);
    expect(find.byKey(const Key('privacy-toggle')), findsOneWidget);
    expect(find.byKey(const Key('user-menu')), findsOneWidget);
    expect(find.text('Gestionar'), findsOneWidget);
    await tester.tap(find.text('Meses'));
    await tester.pumpAndSettle();
    expect(find.text('body /gastos/meses'), findsOneWidget);
  });

  testWidgets('una subpantalla vuelve a su pestaña con "atrás"', (tester) async {
    await _size(tester, const Size(1440, 900));
    await tester.pumpWidget(_app('/gastos/fraccionadas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('page-back')));
    await tester.pumpAndSettle();
    expect(find.text('body /gastos/compromisos'), findsOneWidget);
  });

  testWidgets('tablet: también barra superior; los nombres de los apartados no se cortan', (tester) async {
    await _size(tester, const Size(820, 1180));
    await tester.pumpWidget(_app('/inversiones'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('top-bar')), findsOneWidget);
    expect(tester.takeException(), isNull); // sin desbordes
  });
}
