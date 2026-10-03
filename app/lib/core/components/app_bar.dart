import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../navigation.dart';
import '../privacy.dart';
import '../tokens.dart';

/// Ruta actual, o `null` fuera de go_router (tests de una pantalla suelta, rutas empujadas).
String? currentLocation(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path;
  } catch (_) {
    return null;
  }
}

double _windowWidth() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return 1024;
  final v = views.first;
  return Breakpoints.effective(
      v.physicalSize.width / v.devicePixelRatio, WidgetsBinding.instance.platformDispatcher.textScaleFactor);
}

/// Barra de cada página. En pantallas anchas es la cabecera de la página (título y acciones con
/// nombre; la navegación está en la barra superior del shell). En el móvil añade el modo
/// privacidad y, debajo, las pestañas del apartado. En una subpantalla pone "atrás" hacia su
/// pestaña o su pantalla padre (`backTargetOf`).
class FaroAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FaroAppBar({super.key, this.title, this.actions, this.bottom, this.leading, this.tabs = true});

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  /// `false` para no repetir las pestañas (p. ej. en una pantalla con pestañas propias).
  final bool tabs;

  bool get _compact => Breakpoints.of(_windowWidth()) == SizeClass.compact;

  @override
  Size get preferredSize {
    var h = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    if (bottom == null && tabs && _compact) h += SectionTabs.height;
    return Size.fromHeight(h);
  }

  @override
  Widget build(BuildContext context) {
    final loc = currentLocation(context);
    final compact = context.isCompact;
    final section = loc == null ? -1 : sectionIndexOf(loc);
    final back = loc == null ? null : backTargetOf(loc);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showTabs = bottom == null && tabs && compact && section >= 0 && navSections[section].allTabs.isNotEmpty;
    return AppBar(
      automaticallyImplyLeading: false,
      leading:
          leading ??
          (canPop
              ? const BackButton()
              : back != null
              ? IconButton(
                  key: const Key('page-back'),
                  tooltip: 'Volver a ${tabOf(back)?.path == back ? tabOf(back)!.label : 'la pantalla anterior'}',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(back),
                )
              : null),
      title: title,
      titleSpacing: compact ? null : Space.xl,
      toolbarHeight: kToolbarHeight,
      actions: [
        ...?actions,
        if (compact && section >= 0) const PrivacyToggle(),
        const SizedBox(width: Space.sm),
      ],
      bottom: bottom ?? (showTabs ? SectionTabs(location: loc!) : null),
    );
  }
}

/// Ojo del modo privacidad (en la barra superior y, en el móvil, en cada página).
class PrivacyToggle extends ConsumerWidget {
  const PrivacyToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(privacyProvider);
    return IconButton(
      key: const Key('privacy-toggle'),
      tooltip: on ? 'Mostrar importes' : 'Ocultar importes (modo privacidad)',
      isSelected: on,
      icon: Icon(on ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      onPressed: () => ref.read(privacyProvider.notifier).set(!on),
    );
  }
}

/// Pestañas del apartado de una ruta (y "Gestionar" al final). Se desplazan si no caben y la
/// seleccionada siempre se ve; los nombres nunca se cortan.
class SectionTabs extends StatefulWidget implements PreferredSizeWidget {
  const SectionTabs({super.key, required this.location});
  final String location;

  static const height = 48.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<SectionTabs> createState() => _SectionTabsState();
}

class _SectionTabsState extends State<SectionTabs> {
  final _selectedKey = GlobalKey();

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final c = _selectedKey.currentContext;
    if (c != null && c.mounted) Scrollable.ensureVisible(c, alignment: 0.5, duration: Durations.short4);
  });

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(SectionTabs old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location) _reveal();
  }

  @override
  Widget build(BuildContext context) {
    final i = sectionIndexOf(widget.location);
    if (i < 0) return const SizedBox(height: SectionTabs.height);
    final s = navSections[i];
    final current = tabOf(widget.location);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    Widget tab(NavTab t) {
      final sel = identical(t, current);
      return Semantics(
        selected: sel,
        button: true,
        child: InkWell(
          key: sel ? _selectedKey : Key('tab-${t.path}'),
          onTap: () => context.go(t.path),
          child: Container(
            height: SectionTabs.height,
            padding: const EdgeInsets.symmetric(horizontal: Space.lg),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: sel ? cs.primary : Colors.transparent, width: 3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Space.xs + 2,
              children: [
                if (t.icon != null) Icon(t.icon, size: 18, color: sel ? cs.primary : cs.onSurfaceVariant),
                Text(
                  t.label,
                  style: tt.titleSmall?.copyWith(
                    color: sel ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: SectionTabs.height,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ShaderMask(
              // Degradado en el borde derecho: indica que hay más pestañas al desplazar
              shaderCallback: (r) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withValues(alpha: context.isCompact ? 0.15 : 1),
                ],
                stops: const [0, 0.9, 1],
              ).createShader(r),
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: context.isCompact ? Space.xs : Space.md),
                child: Row(
                  children: [
                    for (final t in s.tabs) tab(t),
                    if (s.manage != null && context.isCompact) tab(s.manage!),
                    if (context.isCompact) const SizedBox(width: Space.xl),
                  ],
                ),
              ),
            ),
          ),
          if (s.manage != null && !context.isCompact) tab(s.manage!),
        ],
      ),
    );
  }
}

/// Acción con nombre de la barra de una página ("Aportar", "Importar"…). En el móvil con el texto
/// del sistema grande no cabe con su nombre: pasa a botón de icono, con el nombre como tooltip y
/// como etiqueta para lectores de pantalla.
class BarAction extends StatelessWidget {
  const BarAction({super.key, required this.icon, required this.label, required this.onPressed, this.tonal = false});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Botón relleno suave (la acción principal de la pantalla).
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final bigText = MediaQuery.textScalerOf(context).scale(10) > 11;
    if (context.isCompact && bigText) {
      return IconButton(tooltip: label, icon: Icon(icon), onPressed: onPressed);
    }
    return tonal
        ? FilledButton.tonalIcon(icon: Icon(icon), label: Text(label), onPressed: onPressed)
        : TextButton.icon(icon: Icon(icon), label: Text(label), onPressed: onPressed);
  }
}
