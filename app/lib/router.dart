import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/lock_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/mfa_page.dart';
import 'features/auth/recovery_codes_page.dart';
import 'features/gastos/cycle_page.dart';
import 'features/gastos/debts_trackers_pages.dart';
import 'features/gastos/fijos_page.dart';
import 'features/gastos/import_settings_pages.dart';
import 'features/imports/import_wizard.dart';
import 'features/gastos/people_page.dart';
import 'features/gastos/stats_page.dart';
import 'features/gastos/installments_page.dart';
import 'features/gastos/months_page.dart';
import 'features/gastos/overview_pages.dart';
import 'features/gastos/panels.dart';
import 'features/gastos/recurring_page.dart';
import 'features/inversiones/assets_page.dart';
import 'features/inversiones/contribution_page.dart';
import 'features/inversiones/contributions_history_page.dart';
import 'features/inversiones/exposure_page.dart';
import 'features/inversiones/inv_page.dart';
import 'features/inversiones/panels.dart';
import 'features/inversiones/performance_page.dart';
import 'features/inversiones/plans_page.dart';
import 'features/inversiones/targets_page.dart';
import 'features/more/more_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/patrimonio/evolution_page.dart';
import 'features/patrimonio/patrimonio_page.dart';
import 'features/patrimonio/tax_report_page.dart';
import 'features/planes/planes_page.dart';
import 'features/shell/home_shell.dart';
import 'features/shell/shared_file_page.dart';
import 'features/shell/splash_page.dart';

/// Puente Riverpod → go_router: re-evalúa `redirect` cada vez que cambia el estado de auth.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

const _authRoutes = {'/splash', '/login', '/2fa', '/codigos', '/bloqueo', '/onboarding'};

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/gastos',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      // Al recargar la web se pasa por /splash: se recuerda la ruta pedida para volver a ella.
      final from = state.uri.queryParameters['from'];
      if (auth is AuthUnknown && loc != '/splash') {
        return Uri(path: '/splash', queryParameters: {'from': state.uri.toString()}).toString();
      }
      final target = switch (auth) {
        AuthUnknown() => '/splash',
        AuthLocked() => '/bloqueo',
        AuthLoggedOut() => '/login',
        AuthMfa() => '/2fa',
        AuthRecoveryCodes() => '/codigos',
        AuthAuthenticated(:final user) when !user.onboardingCompleted => '/onboarding',
        AuthAuthenticated() => null,
      };
      if (target != null) return loc == target ? null : target;
      // Autenticado: fuera de las pantallas de acceso (a la ruta pedida, si la había).
      if (_authRoutes.contains(loc)) {
        return (from != null && from.startsWith('/') && !from.startsWith('/splash')) ? from : '/gastos';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/2fa', builder: (_, _) => const MfaPage()),
      GoRoute(path: '/codigos', builder: (_, _) => const RecoveryCodesPage()),
      GoRoute(path: '/bloqueo', builder: (_, _) => const LockPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/compartido', builder: (_, _) => const SharedFilePage()),
      // Rutas de siempre (no cambia ninguna URL: hay enlaces internos, avisos y "Compartir con
      // Faro" que las usan) más las nuevas del rediseño. Cada apartado tiene sus rutas "planas":
      // las pestañas y el botón atrás de cada página salen de `core/navigation.dart`.
      GoRoute(path: '/planes', redirect: (_, _) => '/planes/independencia'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell, location: state.uri.path),
        branches: [
          StatefulShellBranch(routes: [
            _r('/gastos', (_) => const CyclePage()),
            GoRoute(
              path: '/gastos/meses',
              builder: (_, st) =>
                  MonthsPage(key: ValueKey(st.uri.queryParameters['m']), initial: st.uri.queryParameters['m']),
            ),
            _r('/gastos/meses/resumen', (_) => const ForecastPage()),
            _r('/gastos/estadisticas', (_) => const StatsPage()),
            _r('/gastos/compromisos', (_) => const GastosCommitmentsPage()),
            _r('/gastos/fraccionadas', (_) => const InstallmentsPage()),
            _r('/gastos/recurrentes', (_) => const RecurringPage()),
            _r('/gastos/fijos', (_) => const FixedCostsPage()),
            _r('/gastos/personas', (_) => const PeoplePage()),
            _r('/gastos/personas/:id', (st) => PersonDetailPage(id: st.pathParameters['id']!)),
            _r('/gastos/deudas', (_) => const DebtsPage()),
            _r('/gastos/seguimientos', (_) => const TrackersPage()),
            _r('/gastos/cuentas', (_) => const AccountsPage()),
            _r('/gastos/importar', _importWizard),
            _r('/gastos/ciclos', (_) => const CyclesHistoryPage()),
            _r('/gastos/ciclos/:id', (st) => CycleDetailPage(id: st.pathParameters['id']!)),
            _r('/gastos/gestionar', (_) => const GastosManagePage()),
            _r('/gastos/categorias', (_) => const CategoriesPage()),
            _r('/gastos/ajustes', (_) => const GastosSettingsPage()),
          ]),
          StatefulShellBranch(routes: [
            _r('/inversiones', (_) => const InvestmentsPage()),
            _r('/inversiones/aportar', (_) => const ContributionPage()),
            _r('/inversiones/activo/:id', (st) => AssetDetailPage(id: st.pathParameters['id']!)),
            _r('/inversiones/rendimiento', (_) => const PerformancePage()),
            _r(
              '/inversiones/aportaciones',
              (st) => ContributionsHistoryPage(
                key: ValueKey(st.uri.queryParameters['destino']),
                destination: st.uri.queryParameters['destino'],
              ),
            ),
            _r('/inversiones/exposicion', (_) => const ExposurePage()),
            _r('/inversiones/operaciones', (_) => const OperationsPage()),
            _r('/inversiones/importar', _importWizard),
            _r('/inversiones/gestionar', (_) => const InvManagePage()),
            _r('/inversiones/objetivos', (_) => const TargetsPage()),
            _r('/inversiones/activos', (_) => const AssetsPage()),
            _r('/inversiones/periodicas', (_) => const PlansPage()),
            _r('/inversiones/plataformas', (_) => const PlatformsPage()),
            _r('/inversiones/ajustes', (_) => const InvSettingsPage()),
          ]),
          StatefulShellBranch(routes: [
            _r('/patrimonio', (_) => const PatrimonioPage()),
            _r('/patrimonio/evolucion', (_) => const EvolutionPage()),
            _r('/patrimonio/informe-fiscal', (_) => const TaxReportPage()),
          ]),
          StatefulShellBranch(routes: [
            _r('/planes/independencia', (_) => const PlanesPage()),
            _r('/planes/independencia/supuestos', (_) => const FireAssumptionsPage()),
            _r('/planes/independencia/comparar', (_) => const FireComparePage()),
            _r('/planes/objetivos', (_) => const PlanesPage(tab: 'objetivos')),
            _r('/planes/revision', (_) => const PlanesPage(tab: 'revision')),
            _r('/planes/interes-compuesto', (_) => const PlanesPage(tab: 'interes-compuesto')),
            _r('/planes/impuestos', (_) => const PlanesPage(tab: 'impuestos')),
          ]),
          StatefulShellBranch(routes: [_r('/mas', (_) => const MorePage())]),
        ],
      ),
    ],
  );
});

GoRoute _r(String path, Widget Function(GoRouterState) page) =>
    GoRoute(path: path, builder: (_, st) => page(st));

/// Asistente de importación; `?fuente=myinvestor&paso=2` lleva directo a esa plataforma y paso.
Widget _importWizard(GoRouterState st) => ImportWizardPage(
      key: ValueKey(st.uri.toString()),
      source: st.uri.queryParameters['fuente'],
      step: int.tryParse(st.uri.queryParameters['paso'] ?? ''),
      bankFirst: st.uri.path.startsWith('/gastos'),
    );
