import 'package:flutter/material.dart';

import '../tokens.dart';

/// Acción de una fila (editar, borrar, marcar…). Siempre con nombre: es el tooltip y la
/// etiqueta para lectores de pantalla.
class RowAction {
  const RowAction({required this.icon, required this.label, required this.onPressed, this.key, this.primary = false});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Key? key;

  /// La principal se ve siempre (también en el móvil); el resto, al pasar el ratón o con el foco.
  final bool primary;
}

/// Fila de lista responsive. El título nunca se corta: si no cabe, ocupa otra línea. Las acciones
/// son botones visibles (nada de gestos escondidos): la principal siempre, las demás al pasar el
/// ratón o con el foco en escritorio.
class ListRow extends StatefulWidget {
  const ListRow({
    super.key,
    required this.title,
    this.leading,
    this.lead,
    this.subtitle,
    this.trailing,
    this.actions = const [],
    this.onTap,
    this.muted = false,
    this.extra,
    this.reserveAction = false,
  });

  /// Ancho del hueco de la acción principal en pantallas anchas (botón con texto).
  static const primaryWidth = 176.0;

  final String title;
  final Widget? leading;

  /// Columna fija a la izquierda (p. ej. la fecha "12 oct").
  final String? lead;
  final String? subtitle;
  final Widget? trailing;
  final List<RowAction> actions;
  final VoidCallback? onTap;
  final bool muted;

  /// Algo bajo el subtítulo (p. ej. un botón "Elegir categoría").
  final Widget? extra;

  /// Reserva el hueco de la acción principal aunque esta fila no la tenga, para que los importes
  /// de una lista queden alineados.
  final bool reserveAction;

  @override
  State<ListRow> createState() => _ListRowState();
}

const _primaryWide = ListRow.primaryWidth;

class _ListRowState extends State<ListRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    // Las secundarias, al pasar el ratón o con el foco en escritorio (en el móvil están al tocar la
    // fila: su hoja tiene los mismos botones). Van antes del importe para que este no se mueva.
    final secondary = [
      for (final a in widget.actions)
        if (!a.primary && _hover && context.isWide) a,
    ];
    final primary = widget.actions.where((a) => a.primary).firstOrNull;
    final compact = context.isCompact;
    // Móvil con el texto grande: el importe va debajo del concepto (al lado, el concepto quedaría
    // en una columna estrecha de varias líneas)
    final stacked = compact && MediaQuery.textScalerOf(context).scale(10) > 11.5;
    final amount = widget.trailing == null
        ? null
        : DefaultTextStyle.merge(style: FaroText.amount(context), child: widget.trailing!);
    final sub = [
      if (compact && widget.lead != null) widget.lead!,
      if (widget.subtitle != null && widget.subtitle!.isNotEmpty) widget.subtitle!,
    ].join(' · ');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (f) => setState(() => _hover = f),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
            child: Row(spacing: Space.md, children: [
              if (widget.lead != null && !compact)
                SizedBox(
                  width: MediaQuery.textScalerOf(context).scale(64), // "12 dic 24" en una línea
                  child: Text(widget.lead!, style: FaroText.caption(context).copyWith(fontFeatures: FaroText.tabular)),
                ),
              ?widget.leading,
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.title,
                      style: tt.bodyLarge?.copyWith(color: widget.muted ? cs.onSurfaceVariant : null)),
                  // En el móvil la fecha va delante del subtítulo (más sitio para el concepto)
                  if (sub.isNotEmpty) Text(sub, style: FaroText.caption(context)),
                  if (stacked) ?amount,
                  ?widget.extra,
                ]),
              ),
              for (final a in secondary)
                IconButton(
                  key: a.key,
                  tooltip: a.label,
                  icon: Icon(a.icon, semanticLabel: a.label),
                  onPressed: a.onPressed,
                ),
              if (!stacked) ?amount,
              // Hueco fijo para la acción principal: los importes de todas las filas acaban en la
              // misma columna, la tengan o no. En pantallas anchas lleva su nombre.
              if (widget.reserveAction || primary != null)
                SizedBox(
                  width: compact || !context.isWide ? 48 : _primaryWide,
                  child: primary == null
                      ? null
                      : Align(
                          alignment: Alignment.centerRight,
                          child: compact || !context.isWide
                              ? IconButton(
                                  key: primary.key,
                                  tooltip: primary.label,
                                  icon: Icon(primary.icon, semanticLabel: primary.label),
                                  onPressed: primary.onPressed,
                                )
                              : TextButton.icon(
                                  key: primary.key,
                                  icon: Icon(primary.icon, size: 18),
                                  label: Text(primary.label),
                                  onPressed: primary.onPressed,
                                ),
                        ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
