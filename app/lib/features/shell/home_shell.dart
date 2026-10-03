import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/navigation.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart';
import '../inversiones/prices.dart';
import '../more/more_page.dart';
import '../update/update_banner.dart';

/// Shell de la app (docs/06-rediseno-ui.md §3):
///   · móvil (< 600): barra inferior con Gastos · Inversiones · Patrimonio · Planes · Tú; las
///     pestañas de cada apartado las pone la barra de cada página (`FaroAppBar`).
///   · tablet y escritorio: barra superior con los apartados, precios, privacidad, tema y menú
///     de usuario, y debajo las pestañas del apartado.
/// El contenido va centrado con un ancho máximo (`FaroLayout`).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell, required this.location});
  final StatefulNavigationShell shell;
  final String location;

  void _goSection(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  /// Atrás del sistema (Android): de una subpantalla a su pestaña o pantalla padre; de una
  /// pestaña al inicio de Gastos; en Gastos, sale de la app.
  void _back(BuildContext context) {
    final back = backTargetOf(location);
    if (back != null) return context.go(back);
    if (location != '/gastos') return context.go('/gastos');
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = context.isCompact;
    final maxW =
        routeWidths[location] ?? (wideRoutes.contains(location) ? FaroLayout.maxWidth(width) : FaroLayout.legacy);
    final content = Column(
      children: [
        const UpdateBanner(),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: shell,
            ),
          ),
        ),
      ],
    );
    final body = PopScope(
      canPop: location == '/gastos',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: content,
    );
    if (compact) {
      return Scaffold(
        body: SafeArea(bottom: false, child: body),
        // Los nombres de la barra inferior no crecen con el texto del sistema (como en Android):
        // en 1/5 del ancho, "Inversiones" al 130 % se partiría en dos líneas. Los lectores de
        // pantalla los leen igual.
        bottomNavigationBar: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1,
          child: NavigationBar(
            key: const Key('nav-bar'),
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _goSection,
            destinations: [
              for (final s in navSections)
                NavigationDestination(icon: Icon(s.icon), selectedIcon: Icon(s.selectedIcon), label: s.label),
            ],
          ),
        ),
      );
    }
    final section = sectionIndexOf(location);
    final hasTabs = section >= 0 && navSections[section].allTabs.isNotEmpty;
    return Scaffold(
      body: Column(
        children: [
          // La barra superior usa siempre todo el ancho de escritorio; las pestañas, el del contenido
          _TopBar(
            current: shell.currentIndex,
            location: location,
            onSection: _goSection,
            maxWidth: FaroLayout.maxWidth(width),
          ),
          // Las pestañas, siempre en el mismo sitio (el ancho de la barra superior), sea cual sea
          // el ancho del contenido de cada pantalla
          if (hasTabs)
            _Centered(
              maxWidth: FaroLayout.maxWidth(width),
              child: SectionTabs(location: location),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Rutas con el ancho de escritorio completo (las ya rediseñadas). El resto, la columna de antes
/// hasta que se rediseñen (fases 2-7).
const wideRoutes = {'/gastos/compromisos', '/gastos/gestionar', '/inversiones/gestionar', '/inversiones/rendimiento'};

/// Rutas con un ancho propio: Este ciclo = lista legible + panel lateral, centrados.
const routeWidths = {'/gastos': FaroLayout.readable + Space.xl + FaroLayout.sidePanel + 2 * Space.lg};

class _Centered extends StatelessWidget {
  const _Centered({required this.maxWidth, required this.child});
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.current, required this.location, required this.onSection, required this.maxWidth});
  final int current;
  final String location;
  final ValueChanged<int> onSection;
  final double maxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final medium = context.sizeClass == SizeClass.medium;
    final bigText = MediaQuery.textScalerOf(context).scale(10) > 11;
    final section = sectionIndexOf(location);
    final prices = section >= 0 && navSections[section].prices;
    final compactExtras = medium && bigText;
    // En tablet, si los cuatro nombres no caben enteros (texto grande), solo los iconos, con el nombre
    // como tooltip y etiqueta para lectores de pantalla
    var iconsOnly = false;
    if (medium) {
      final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: MediaQuery.textScalerOf(context));
      var needed = 0.0;
      for (var i = 0; i < 4; i++) {
        painter.text = TextSpan(
            text: navSections[i].label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600));
        painter.layout();
        needed += painter.width + 2 * (Space.sm + 2) + 4;
      }
      final width = math.min(maxWidth, MediaQuery.sizeOf(context).width);
      final fixed = 2 * Space.sm + 40 + Space.sm + 48 * (compactExtras ? 2 : 3) + (prices && !compactExtras ? 48 : 0);
      iconsOnly = needed > width - fixed;
    }
    return Material(
      key: const Key('top-bar'),
      color: cs.surfaceContainer,
      child: SafeArea(
        bottom: false,
        child: _Centered(
          maxWidth: maxWidth,
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: medium ? Space.sm : Space.lg),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(Radii.sm),
                    onTap: () => onSection(0),
                    child: Padding(
                      padding: const EdgeInsets.all(Space.xs),
                      child: FaroLogo(size: 32, withName: !medium),
                    ),
                  ),
                  SizedBox(width: medium ? Space.sm : Space.xl),
                  for (var i = 0; i < 4; i++)
                    _SectionButton(index: i, selected: current == i, onTap: onSection, iconOnly: iconsOnly),
                  const Spacer(),
                  // Tablet con el texto grande: sin el estado de precios ni el tema (están en la página
                  // y en Tú), para que los cuatro apartados quepan enteros
                  if (prices && !compactExtras) PricesStatus(compact: medium),
                  const PrivacyToggle(),
                  if (!compactExtras) const _ThemeToggle(),
                  const _UserMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({required this.index, required this.selected, required this.onTap, this.iconOnly = false});
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final s = navSections[index];
    final cs = Theme.of(context).colorScheme;
    final medium = context.sizeClass == SizeClass.medium;
    if (iconOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          key: Key('section-${s.root}'),
          tooltip: s.label,
          isSelected: selected,
          style: IconButton.styleFrom(
            foregroundColor: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            backgroundColor: selected ? cs.secondaryContainer : null,
          ),
          icon: Icon(selected ? s.selectedIcon : s.icon),
          onPressed: () => onTap(index),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        selected: selected,
        // En tablet, solo el nombre (sin icono) para que quepan los cuatro sin cortarse
        child: TextButton.icon(
          key: Key('section-${s.root}'),
          style: TextButton.styleFrom(
            foregroundColor: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            backgroundColor: selected ? cs.secondaryContainer : null,
            padding: EdgeInsets.symmetric(horizontal: medium ? Space.sm + 2 : Space.md, vertical: Space.md),
          ),
          icon: medium ? null : Icon(selected ? s.selectedIcon : s.icon, size: 20),
          label: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => onTap(index),
        ),
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      key: const Key('theme-toggle'),
      tooltip: dark ? 'Tema claro' : 'Tema oscuro',
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(Theme.of(context).brightness),
    );
  }
}

/// Menú de usuario: lo que en el móvil está en "Tú".
class _UserMenu extends ConsumerWidget {
  const _UserMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final name = user == null ? '' : (user.displayName.isNotEmpty ? user.displayName : user.email);
    return PopupMenuButton<String>(
      key: const Key('user-menu'),
      tooltip: 'Tu cuenta',
      position: PopupMenuPosition.under,
      onSelected: (v) async {
        switch (v) {
          case 'cuenta':
            context.go('/mas');
          case 'xlsx' || 'json':
            await exportData(context, ref, v);
          case 'android':
            await launchUrl(Uri.parse('${Env.apiOrigin}/descargar/'));
          case 'salir':
            await confirmLogout(context, ref);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(enabled: false, child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'cuenta',
          child: ListTile(leading: Icon(Icons.person_outline), title: Text('Tu cuenta y ajustes')),
        ),
        const PopupMenuItem(
          value: 'xlsx',
          child: ListTile(leading: Icon(Icons.table_view_outlined), title: Text('Exportar a Excel')),
        ),
        const PopupMenuItem(
          value: 'json',
          child: ListTile(leading: Icon(Icons.data_object), title: Text('Exportar copia completa (JSON)')),
        ),
        if (kIsWeb)
          const PopupMenuItem(
            value: 'android',
            child: ListTile(leading: Icon(Icons.android), title: Text('Descargar la app Android')),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'salir',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Cerrar sesión')),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.sm),
        child: CircleAvatar(radius: 16, child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
      ),
    );
  }
}
