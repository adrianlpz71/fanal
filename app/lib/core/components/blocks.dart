import 'package:flutter/material.dart';

import '../tokens.dart';

/// Cabecera de sección: título en versalitas, un dato a la derecha (recuento o total) y una
/// acción opcional.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.action, this.padding});
  final String title;
  final Widget? trailing;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final style = FaroText.overline(context);
    final head = Row(children: [
      Expanded(child: Text(title.toUpperCase(), style: style)),
      // Con texto grande, el dato de la derecha también puede pasar a otra línea
      if (trailing != null)
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DefaultTextStyle.merge(style: style, textAlign: TextAlign.end, child: trailing!),
          ),
        ),
    ]);
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.xs),
      child: action == null
          ? head
          // Si la acción no cabe al lado del título (móvil, texto grande), va debajo
          : OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              overflowAlignment: OverflowBarAlignment.start,
              spacing: Space.sm,
              children: [
                Row(mainAxisSize: MainAxisSize.min, spacing: Space.sm, children: [
                  Flexible(child: Text(title.toUpperCase(), style: style)),
                  if (trailing != null) DefaultTextStyle.merge(style: style, child: trailing!),
                ]),
                action!,
              ],
            ),
    );
  }
}

/// Estado vacío: qué pasa y qué hacer (siempre con una acción si la hay).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.actionLabel,
    this.onAction,
    this.secondary,
  });
  final IconData icon;
  final String title;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.xxl),
      child: Column(mainAxisSize: MainAxisSize.min, spacing: Space.sm, children: [
        Icon(icon, size: 40, color: cs.onSurfaceVariant),
        Text(title, style: tt.titleMedium, textAlign: TextAlign.center),
        if (text != null) Text(text!, style: FaroText.caption(context), textAlign: TextAlign.center),
        if (actionLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: FilledButton.tonal(
              // 48 px también en escritorio (allí la densidad por defecto lo deja en ~32)
              style: FilledButton.styleFrom(minimumSize: const Size(64, 48), visualDensity: VisualDensity.standard),
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ),
        ?secondary,
      ]),
    );
  }
}

/// Bloque gris que ocupa el sitio del contenido mientras carga (en vez de un spinner).
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height = 16, this.width, this.radius = Radii.sm});
  final double height;
  final double? width;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: 'Cargando',
      child: FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(widget.radius)),
        ),
      ),
    );
  }
}

/// Esqueleto de una pantalla típica: fila de KPI y una lista.
class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key, this.rows = 6, this.kpis = 2});
  final int rows;
  final int kpis;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Row(spacing: Space.md, children: [
            for (var i = 0; i < kpis; i++) const Expanded(child: Skeleton(height: 84, radius: Radii.md)),
          ]),
          const SizedBox(height: Space.xl),
          for (var i = 0; i < rows; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Space.sm),
              child: Row(spacing: Space.md, children: [
                Skeleton(height: 36, width: 36, radius: 18),
                Expanded(child: Skeleton(height: 14)),
                Skeleton(height: 14, width: 72),
              ]),
            ),
        ],
      );
}

/// Barra con rango mínimo–máximo, marca del objetivo y valor actual (en tanto por uno, 0–1).
/// Para la asignación de la cartera o un presupuesto.
class BulletBar extends StatelessWidget {
  const BulletBar({
    super.key,
    required this.value,
    this.target,
    this.min,
    this.max,
    this.scaleMax = 1,
    this.color,
    this.height = 12,
    this.semanticLabel,
  });
  final double value;
  final double? target, min, max;
  final double scaleMax;
  final Color? color;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = context.faro;
    double x(double v, double w) => (v / scaleMax).clamp(0, 1) * w;
    final inRange = min == null || max == null || (value >= min! - 1e-9 && value <= max! + 1e-9);
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height + 6,
        child: LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth;
          return Stack(clipBehavior: Clip.none, children: [
            Positioned(
              top: 3,
              left: 0,
              right: 0,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
            if (min != null && max != null)
              Positioned(
                top: 3,
                left: x(min!, w),
                width: (x(max!, w) - x(min!, w)).clamp(2, w),
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: f.gain.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            Positioned(
              top: 3 + height * 0.25,
              left: 0,
              width: x(value, w),
              height: height * 0.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color ?? (inRange ? cs.primary : f.warning),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
            if (target != null)
              Positioned(
                top: 0,
                left: (x(target!, w) - 1.5).clamp(0, w - 3),
                width: 3,
                height: height + 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(2)),
                ),
              ),
          ]);
        }),
      ),
    );
  }
}

/// Tramo de una `SummaryBar`.
class SummarySegment {
  const SummarySegment({required this.id, required this.label, required this.value, required this.color, this.text});
  final String id;
  final String label;
  final double value; // magnitud (≥ 0)
  final Color color;
  final String? text; // importe ya formateado
}

/// Barra apilada pulsable: cada tramo es proporcional a su valor y, al tocarlo (o su leyenda),
/// se selecciona (p. ej. para filtrar una lista). Vuelve a tocar para quitar el filtro.
class SummaryBar extends StatelessWidget {
  const SummaryBar({super.key, required this.segments, this.selected, this.onSelect});
  final List<SummarySegment> segments;
  final String? selected;
  final ValueChanged<String?>? onSelect;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, x) => s + (x.value > 0 ? x.value : 0));
    final cs = Theme.of(context).colorScheme;
    void tap(String id) => onSelect?.call(selected == id ? null : id);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Radii.sm),
        child: SizedBox(
          height: 14,
          child: Row(children: [
            for (final s in segments)
              if (s.value > 0 && total > 0)
                Expanded(
                  flex: (s.value / total * 1000).round().clamp(1, 1000),
                  child: GestureDetector(
                    onTap: () => tap(s.id),
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      color: selected == null || selected == s.id ? s.color : s.color.withValues(alpha: 0.3),
                    ),
                  ),
                ),
          ]),
        ),
      ),
      Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
        for (final s in segments)
          FilterChip(
            key: Key('summary-${s.id}'),
            avatar: CircleAvatar(backgroundColor: s.color, radius: 6),
            label: Text(s.text == null ? s.label : '${s.label} ${s.text}'),
            selected: selected == s.id,
            showCheckmark: false,
            side: BorderSide(color: cs.outlineVariant),
            onSelected: onSelect == null ? null : (_) => tap(s.id),
          ),
      ]),
    ]);
  }
}

/// Supuesto editable en forma de píldora ("Gasto 2.000 €/mes ✎"): se ve el valor y se toca para
/// cambiarlo.
class EditChip extends StatelessWidget {
  const EditChip({super.key, required this.label, required this.value, required this.onTap, this.note});
  final String label;
  final String value;
  final String? note; // p. ej. "auto"
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '$label: $value${note == null ? '' : ' ($note)'}. Cambiar',
      excludeSemantics: true,
      child: Material(
        color: cs.surfaceContainerHigh,
        shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
              // Wrap: con texto grande, el valor pasa debajo de la etiqueta en vez de salirse
              child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: Space.xs, children: [
                Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                Text(value, style: tt.labelLarge?.copyWith(fontFeatures: FaroText.tabular)),
                if (note != null) Text('· $note', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                Icon(Icons.edit_outlined, size: 14, color: cs.onSurfaceVariant),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una barra de [BarList].
class BarItem {
  const BarItem({required this.label, required this.value, required this.fraction, this.detail, this.color});
  final String label;
  final String value; // ya formateado
  final double fraction; // 0..1 respecto a la mayor
  final String? detail;
  final Color? color;
}

/// Barras horizontales con su etiqueta y su valor ("−100 €/mes → 2 años antes", tramos de una
/// escala…). La longitud de cada barra es su `fraction`.
class BarList extends StatelessWidget {
  const BarList({super.key, required this.items});
  final List<BarItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      for (final i in items)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
            Expanded(child: Text(i.label, style: tt.bodyMedium)),
            Flexible(
              child: Text(i.value,
                  textAlign: TextAlign.end,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontFeatures: FaroText.tabular)),
            ),
          ]),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(
              value: i.fraction.clamp(0.0, 1.0),
              minHeight: 8,
              color: i.color ?? cs.primary,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
          if (i.detail != null) Text(i.detail!, style: FaroText.caption(context)),
        ]),
    ]);
  }
}

/// Pasos de un asistente ("1 Plataforma ── 2 Cómo descargarlo ── …"). En pantallas estrechas,
/// solo "Paso N de M · nombre" con la barra de progreso. Los pasos ya hechos se pueden tocar.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.steps, required this.current, this.onTap});
  final List<String> steps;
  final int current; // 0..n-1
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, box) {
      // Cabe en una fila si los nombres, sus números y un trozo de línea entre pasos caben enteros
      final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: MediaQuery.textScalerOf(context));
      var needed = (steps.length - 1) * 16.0; // un trozo mínimo de línea entre pasos
      for (final s in steps) {
        painter.text = TextSpan(text: s, style: tt.labelLarge);
        painter.layout();
        needed += painter.width + 24 + Space.xs * 3; // nombre, círculo y márgenes
      }
      if (box.maxWidth < needed) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
          Text('Paso ${current + 1} de ${steps.length} · ${steps[current]}', style: tt.titleSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(value: (current + 1) / steps.length, minHeight: 6),
          ),
        ]);
      }
      return Row(children: [
        for (final (i, s) in steps.indexed) ...[
          if (i > 0) Expanded(child: Divider(color: i <= current ? cs.primary : cs.outlineVariant, thickness: 1.5)),
          InkWell(
            key: Key('step-$i'),
            borderRadius: BorderRadius.circular(Radii.sm),
            onTap: onTap != null && i < current ? () => onTap!(i) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xs),
              child: Row(mainAxisSize: MainAxisSize.min, spacing: Space.xs, children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i <= current ? cs.primary : cs.surfaceContainerHighest,
                  foregroundColor: i <= current ? cs.onPrimary : cs.onSurfaceVariant,
                  child: i < current
                      ? const Icon(Icons.check, size: 14)
                      : Text('${i + 1}', style: tt.labelMedium?.copyWith(color: i <= current ? cs.onPrimary : null)),
                ),
                Text(s, style: tt.labelLarge?.copyWith(color: i == current ? cs.onSurface : cs.onSurfaceVariant)),
              ]),
            ),
          ),
        ],
      ]);
    });
  }
}
