import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';

export 'components/app_bar.dart';
export 'components/blocks.dart';
export 'components/feedback.dart';
export 'components/file_drop.dart';
export 'components/glossary.dart';
export 'components/indicators.dart';
export 'components/list_row.dart';
export 'components/manage.dart';
export 'components/markdown.dart';
export 'components/menu.dart';
export 'tokens.dart';

class FaroLogo extends StatelessWidget {
  const FaroLogo({super.key, this.size = 40, this.withName = false});
  final double size;
  final bool withName;

  @override
  Widget build(BuildContext context) {
    // El icono de Fanal (el fanal sobre el horizonte); lo genera scripts/brand_icons.py
    final icon = Semantics(
      label: 'Fanal',
      image: true,
      child: Image.asset('assets/brand/fanal-128.png', width: size, height: size, filterQuality: FilterQuality.medium),
    );
    if (!withName) return icon;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      icon,
      SizedBox(width: size / 3),
      Text('Fanal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          )),
    ]);
  }
}

/// Contenedor centrado y con ancho máximo para formularios (se ve bien en web ancha y móvil).
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      );
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key, this.textAlign});
  final String? message;

  /// Centrado en las pantallas de acceso (bloqueo, login), donde todo va centrado.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(message!, textAlign: textAlign, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}

/// Formulario en lista: mismo margen y la misma separación entre campos en toda la app. En pantallas
/// anchas, la columna no pasa de `FaroLayout.readable` (un "28" no necesita un campo de 1.000 px) y
/// abajo deja sitio para el botón flotante.
class FormListView extends StatelessWidget {
  const FormListView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 96),
    this.shrinkWrap = false,
    this.maxWidth = FaroLayout.readable,
  });
  final List<Widget> children;
  final EdgeInsets padding;
  final bool shrinkWrap; // en diálogos
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final extra = box.maxWidth.isFinite ? ((box.maxWidth - maxWidth) / 2).clamp(0.0, double.infinity) : 0.0;
        return ListView(
          padding: padding.copyWith(left: padding.left + extra, right: padding.right + extra),
          shrinkWrap: shrinkWrap,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: FaroTheme.fieldGap),
              children[i],
            ],
          ],
        );
      });
}

/// Campos en fila con un ancho mínimo cada uno: si no caben todos, se reparten en filas (de dos en
/// dos, p. ej.) y, si ni así, uno debajo de otro. Una etiqueta nunca se corta por falta de ancho
/// (regla de diseño de toda la app).
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children, this.minWidth = 200, this.flex});
  final List<Widget> children;
  final double minWidth;
  final List<int>? flex; // solo cuando caben todos en una fila

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final n = children.length;
        final cols = ((box.maxWidth + _gap) ~/ (minWidth + _gap)).clamp(1, n);
        if (cols == 1) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: children);
        }
        Widget row(List<Widget> items, {bool useFlex = false}) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: _gap,
              children: [
                for (var i = 0; i < cols; i++)
                  Expanded(
                    flex: useFlex ? (flex?[i] ?? 1) : 1,
                    child: i < items.length ? items[i] : const SizedBox.shrink(),
                  ),
              ],
            );
        if (cols == n) {
          // Las proporciones solo si con ellas cada campo sigue teniendo su ancho mínimo (si no, el
          // estrecho cortaría su etiqueta: "Día del m…")
          final f = flex;
          final total = f == null ? 0 : f.take(n).fold<int>(0, (a, b) => a + b);
          final room = box.maxWidth - _gap * (n - 1);
          final flexOk = f == null || f.take(n).every((x) => room * x / total >= minWidth);
          return row(children, useFlex: flexOk);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
          for (var i = 0; i < n; i += cols) row(children.sublist(i, (i + cols).clamp(0, n))),
        ]);
      });
}

/// Bloque con título y contenido en una tarjeta (listas de resultados, informes). Igual en toda
/// la app.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: tt.titleMedium),
              if (subtitle != null) Text(subtitle!, style: tt.bodySmall),
            ]),
          ),
          const SizedBox(height: 4),
          ...children,
        ]),
      ),
    );
  }
}

/// Título de pantalla: si no cabe (móvil, acciones a la derecha) se reduce un poco en vez de
/// cortarse con "…". Se usa en todas las AppBar.
class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(text),
      );
}
