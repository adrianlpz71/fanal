import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tokens.dart';

/// Tarjeta de un panel "Gestionar" o "Compromisos": icono, nombre, una línea de qué es y un dato
/// en vivo. Sustituye a las entradas del antiguo menú "⋮".
class ManageCard extends StatelessWidget {
  const ManageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.live,
    this.route,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;

  /// Dato en vivo ("12 activas · 978 € pendientes"). `null` mientras carga.
  final String? live;
  final String? route;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap ?? (route == null ? null : () => context.go(route!)),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: cs.onPrimaryContainer, size: 22),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
                Text(title, style: tt.titleMedium),
                Text(description, style: FaroText.caption(context)),
                const SizedBox(height: Space.xs),
                if (live == null)
                  const SizedBox(height: 18)
                else
                  Text(live!, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: FaroText.tabular)),
              ]),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}

/// Rejilla de `ManageCard`: 1 columna en el móvil, 2 en tablet y 3 en escritorio.
class ManageGrid extends StatelessWidget {
  const ManageGrid({super.key, required this.children, this.minWidth = 300});
  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final cols = ((box.maxWidth + Space.md) ~/ (minWidth + Space.md)).clamp(1, 3);
        final w = (box.maxWidth - Space.md * (cols - 1)) / cols;
        return Wrap(spacing: Space.md, runSpacing: Space.md, children: [
          for (final c in children) SizedBox(width: w, child: c),
        ]);
      });
}
