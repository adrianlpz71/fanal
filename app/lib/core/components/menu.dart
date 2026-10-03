import 'package:flutter/material.dart';

/// Opción de un `OptionsMenu`.
class MenuOption<T> {
  const MenuOption(this.value, this.label, {this.icon, this.destructive = false});
  final T value;
  final String label;
  final IconData? icon;

  /// Se pinta en el color de error (archivar, borrar…).
  final bool destructive;
}

/// Menú "⋮" de opciones de una fila o tarjeta (no de navegación entre secciones). Siempre con
/// nombre, que es el tooltip y la etiqueta para lectores de pantalla.
class OptionsMenu<T> extends StatelessWidget {
  const OptionsMenu({super.key, required this.options, required this.onSelected, this.tooltip = 'Opciones'});
  final List<MenuOption<T>> options;
  final ValueChanged<T> onSelected;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem<T>(
            key: Key('menu-${o.label}'),
            value: o.value,
            child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
              if (o.icon != null) Icon(o.icon, size: 20, color: o.destructive ? error : null),
              Flexible(child: Text(o.label, style: o.destructive ? TextStyle(color: error) : null)),
            ]),
          ),
      ],
    );
  }
}
