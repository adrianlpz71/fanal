import 'package:flutter/material.dart';

/// Estructura de navegación de Faro (docs/06-rediseno-ui.md §3): apartados, pestañas de cada uno
/// y el panel "Gestionar". Es la única fuente: la usan la barra superior, la inferior, las
/// pestañas, el botón "atrás" de cada página y los tests de rutas.
class NavTab {
  const NavTab(this.label, this.path, {this.icon, this.also = const []});
  final String label;
  final String path;
  final IconData? icon;

  /// Subpantallas que cuelgan de esta pestaña (prefijos de ruta).
  final List<String> also;
}

class NavSection {
  const NavSection({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.root,
    this.tabs = const [],
    this.manage,
    this.prices = false,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String root;
  final List<NavTab> tabs;
  final NavTab? manage;

  /// Enseña "Precios a … ⟳" en la barra (Inversiones y Patrimonio).
  final bool prices;

  List<NavTab> get allTabs => [...tabs, ?manage];
}

const navSections = [
  NavSection(
    label: 'Gastos',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    root: '/gastos',
    tabs: [
      NavTab('Este ciclo', '/gastos'),
      NavTab('Meses', '/gastos/meses'),
      NavTab('Estadísticas', '/gastos/estadisticas'),
      NavTab('Compromisos', '/gastos/compromisos', also: [
        '/gastos/fraccionadas', '/gastos/recurrentes', '/gastos/fijos', '/gastos/deudas', '/gastos/personas',
        '/gastos/seguimientos',
      ]),
      NavTab('Cuentas', '/gastos/cuentas', also: ['/gastos/importar', '/gastos/ciclos']),
    ],
    manage: NavTab('Gestionar', '/gastos/gestionar',
        icon: Icons.tune, also: ['/gastos/categorias', '/gastos/ajustes']),
  ),
  NavSection(
    label: 'Inversiones',
    icon: Icons.show_chart_outlined,
    selectedIcon: Icons.show_chart,
    root: '/inversiones',
    prices: true,
    tabs: [
      NavTab('Cartera', '/inversiones', also: ['/inversiones/aportar', '/inversiones/activo']),
      NavTab('Rendimiento', '/inversiones/rendimiento'),
      NavTab('Aportaciones', '/inversiones/aportaciones'),
      NavTab('Exposición', '/inversiones/exposicion'),
      NavTab('Operaciones', '/inversiones/operaciones', also: ['/inversiones/importar']),
    ],
    manage: NavTab('Gestionar', '/inversiones/gestionar', icon: Icons.tune, also: [
      '/inversiones/objetivos', '/inversiones/activos', '/inversiones/periodicas', '/inversiones/plataformas',
      '/inversiones/ajustes',
    ]),
  ),
  NavSection(
    label: 'Patrimonio',
    icon: Icons.account_balance_outlined,
    selectedIcon: Icons.account_balance,
    root: '/patrimonio',
    prices: true,
    tabs: [
      NavTab('Resumen', '/patrimonio'),
      NavTab('Evolución', '/patrimonio/evolucion'),
      NavTab('Informe fiscal', '/patrimonio/informe-fiscal'),
    ],
  ),
  NavSection(
    label: 'Planes',
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
    root: '/planes',
    tabs: [
      NavTab('Independencia', '/planes/independencia'),
      NavTab('Objetivos', '/planes/objetivos'),
      NavTab('Revisión', '/planes/revision'),
      NavTab('Interés compuesto', '/planes/interes-compuesto'),
      NavTab('Impuestos', '/planes/impuestos'),
    ],
  ),
  NavSection(
    label: 'Tú',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    root: '/mas',
  ),
];

bool _under(String loc, String p) => loc == p || loc.startsWith('$p/');

/// Índice del apartado de una ruta (o -1 si está fuera del shell).
int sectionIndexOf(String loc) {
  for (var i = 0; i < navSections.length; i++) {
    if (_under(loc, navSections[i].root)) return i;
  }
  return -1;
}

/// Pestaña (o "Gestionar") a la que pertenece una ruta: la coincidencia más específica. La raíz
/// del apartado solo coincide consigo misma.
NavTab? tabOf(String loc) {
  final i = sectionIndexOf(loc);
  if (i < 0) return null;
  final s = navSections[i];
  NavTab? best;
  var bestLen = -1;
  for (final t in s.allTabs) {
    for (final p in [t.path, ...t.also]) {
      final hit = p == s.root ? loc == p : _under(loc, p);
      if (hit && p.length > bestLen) {
        best = t;
        bestLen = p.length;
      }
    }
  }
  return best ?? (s.tabs.isEmpty ? null : s.tabs.first);
}

/// Rutas fijas (sin parámetros) de la app, para saber si el "padre" de una ruta existe.
const staticRoutes = {
  '/gastos', '/gastos/meses', '/gastos/meses/resumen', '/gastos/estadisticas', '/gastos/compromisos',
  '/gastos/fraccionadas', '/gastos/recurrentes', '/gastos/fijos', '/gastos/cuentas', '/gastos/importar',
  '/gastos/personas', '/gastos/deudas', '/gastos/seguimientos', '/gastos/categorias', '/gastos/ajustes',
  '/gastos/ciclos', '/gastos/gestionar',
  '/inversiones', '/inversiones/aportar', '/inversiones/objetivos', '/inversiones/activos',
  '/inversiones/plataformas', '/inversiones/ajustes', '/inversiones/importar', '/inversiones/periodicas',
  '/inversiones/exposicion', '/inversiones/rendimiento', '/inversiones/aportaciones', '/inversiones/operaciones', '/inversiones/gestionar',
  '/patrimonio', '/patrimonio/evolucion', '/patrimonio/informe-fiscal',
  '/planes/independencia', '/planes/independencia/supuestos', '/planes/independencia/comparar',
  '/planes/objetivos', '/planes/revision', '/planes/interes-compuesto', '/planes/impuestos',
  '/mas',
};

/// A dónde vuelve el botón "atrás" de una subpantalla: a su pantalla padre si existe (p. ej.
/// Personas para el detalle de una persona) o a su pestaña. `null` en las pestañas.
String? backTargetOf(String loc) {
  final tab = tabOf(loc);
  if (tab == null || loc == tab.path) return null;
  final cut = loc.lastIndexOf('/');
  final parent = cut > 0 ? loc.substring(0, cut) : null;
  final root = navSections[sectionIndexOf(loc)].root;
  if (parent != null && parent != root && staticRoutes.contains(parent)) return parent;
  return tab.path;
}
