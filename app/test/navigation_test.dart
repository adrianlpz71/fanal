import 'package:faro/core/navigation.dart';
import 'package:faro/core/api.dart';
import 'package:faro/core/notifications.dart';
import 'package:faro/core/token_store.dart';
import 'package:faro/features/auth/auth_controller.dart';
import 'package:faro/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Auth extends AuthController {
  @override
  AuthState build() => const AuthLoggedOut();
}

/// Las rutas de antes del rediseño: tienen que seguir funcionando con la misma URL (enlaces
/// internos, avisos de Android y "Compartir con Faro").
const oldRoutes = [
  '/gastos', '/gastos/meses', '/gastos/meses?m=2026-11', '/gastos/meses/resumen', '/gastos/fraccionadas',
  '/gastos/recurrentes', '/gastos/fijos', '/gastos/cuentas', '/gastos/estadisticas', '/gastos/importar',
  '/gastos/personas', '/gastos/personas/x1', '/gastos/deudas', '/gastos/seguimientos', '/gastos/categorias',
  '/gastos/ajustes', '/gastos/ciclos', '/gastos/ciclos/c1',
  '/inversiones', '/inversiones/aportar', '/inversiones/objetivos', '/inversiones/activos',
  '/inversiones/activo/a1', '/inversiones/plataformas', '/inversiones/ajustes', '/inversiones/importar',
  '/inversiones/periodicas', '/inversiones/exposicion',
  '/patrimonio', '/patrimonio/informe-fiscal',
  '/planes', '/mas', '/compartido', '/login', '/2fa', '/codigos', '/bloqueo', '/onboarding', '/splash',
];

const newRoutes = [
  '/gastos/compromisos', '/gastos/gestionar', '/inversiones/rendimiento', '/inversiones/aportaciones',
  '/inversiones/operaciones',
  '/inversiones/gestionar', '/planes/independencia', '/planes/independencia/supuestos',
  '/planes/independencia/comparar', '/planes/objetivos', '/planes/revision', '/planes/interes-compuesto',
  '/planes/impuestos',
];

void main() {
  test('todas las rutas de antes y las nuevas existen (ninguna da error)', () {
    final c = ProviderContainer(overrides: [
      authProvider.overrideWith(_Auth.new),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ]);
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    for (final r in [...oldRoutes, ...newRoutes, ...AvisoRoute.all]) {
      final m = router.configuration.findMatch(Uri.parse(r));
      expect(m.isError, isFalse, reason: r);
      expect(m.isEmpty, isFalse, reason: r);
    }
  });

  test('cada ruta del shell cuelga de un apartado y de una pestaña (o de Gestionar)', () {
    for (final r in staticRoutes) {
      expect(sectionIndexOf(r), greaterThanOrEqualTo(0), reason: r);
      if (r != '/mas') expect(tabOf(r), isNotNull, reason: r);
    }
  });

  test('pestaña de cada ruta: la más específica; la raíz solo coincide consigo misma', () {
    expect(tabOf('/gastos')!.label, 'Este ciclo');
    expect(tabOf('/gastos/fraccionadas')!.label, 'Compromisos');
    expect(tabOf('/gastos/personas/x1')!.label, 'Compromisos');
    expect(tabOf('/gastos/importar')!.label, 'Cuentas');
    expect(tabOf('/gastos/meses/resumen')!.label, 'Meses');
    expect(tabOf('/gastos/categorias')!.label, 'Gestionar');
    expect(tabOf('/inversiones/activo/a1')!.label, 'Cartera');
    expect(tabOf('/inversiones/importar')!.label, 'Operaciones');
    expect(tabOf('/inversiones/objetivos')!.label, 'Gestionar');
    expect(tabOf('/planes/independencia/comparar')!.label, 'Independencia');
  });

  test('atrás: a la pantalla padre si existe, si no a la pestaña; en las pestañas, nada', () {
    expect(backTargetOf('/gastos'), isNull);
    expect(backTargetOf('/gastos/compromisos'), isNull);
    expect(backTargetOf('/gastos/fraccionadas'), '/gastos/compromisos');
    expect(backTargetOf('/gastos/personas/x1'), '/gastos/personas');
    expect(backTargetOf('/gastos/ciclos/c1'), '/gastos/ciclos');
    expect(backTargetOf('/gastos/ciclos'), '/gastos/cuentas');
    expect(backTargetOf('/gastos/meses/resumen'), '/gastos/meses');
    expect(backTargetOf('/inversiones/activo/a1'), '/inversiones');
    expect(backTargetOf('/inversiones/ajustes'), '/inversiones/gestionar');
    expect(backTargetOf('/planes/independencia/comparar'), '/planes/independencia');
    expect(backTargetOf('/mas'), isNull);
  });

  test('Planes en el orden pedido (las calculadoras al final)', () {
    final planes = navSections.firstWhere((s) => s.root == '/planes');
    expect(planes.tabs.map((t) => t.label),
        ['Independencia', 'Objetivos', 'Revisión', 'Interés compuesto', 'Impuestos']);
  });
}
