import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/indicators.dart' show InfoTip;
import '../dates.dart';
import '../theme.dart';
import '../tokens.dart';

/// Formularios de Faro: todos los campos de la app salen de aquí (un test de arquitectura lo
/// vigila), así que la etiqueta, la separación (`FaroTheme.fieldGap`), el teclado numérico con
/// coma y la validación son iguales en todas partes.

/// Acción "guardar" del formulario en el que está un campo: Enter en un campo de una línea
/// guarda (en web) sin que cada campo lo tenga que saber.
class FormSubmitScope extends InheritedWidget {
  const FormSubmitScope({super.key, required this.onSubmit, required super.child});
  final VoidCallback? onSubmit;

  static VoidCallback? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormSubmitScope>()?.onSubmit;

  @override
  bool updateShouldNotify(FormSubmitScope old) => old.onSubmit != onSubmit;
}

class FaroTextField extends StatelessWidget {
  const FaroTextField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.hint,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.error,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.autofillHints,
    this.focusNode,
    this.textInputAction,
    this.style,
    this.info,
  });

  final String label;
  final TextEditingController? controller;
  final String? helper, hint, suffix, error;
  final Widget? prefixIcon, suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus, enabled, obscureText;
  final int? maxLines, minLines;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextStyle? style;

  /// Clave del glosario: añade una ⓘ al final del campo que explica el término.
  final String? info;

  @override
  Widget build(BuildContext context) {
    final submit = FormSubmitScope.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      style: style,
      onChanged: onChanged,
      onSubmitted: onSubmitted ?? (maxLines == 1 && submit != null ? (_) => submit() : null),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon ?? (info == null ? null : InfoTip(info!)),
        errorText: error,
      ),
    );
  }
}

final _numberChars = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-−]'));

/// Importe en euros: teclado numérico, coma decimal (se acepta también el punto) y "€" fijo.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.error,
    this.suffix = '€',
    this.allowNegative = false,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.style,
    this.info,
    this.textAlign = TextAlign.start,
  });
  final String label;
  final TextEditingController? controller;
  final String? helper, error, info;
  final String suffix;
  final bool allowNegative, autofocus, enabled;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextStyle? style;
  final TextAlign textAlign; // a la derecha en filas de importes (columna de cifras)

  @override
  Widget build(BuildContext context) => FaroTextField(
        label: label,
        controller: controller,
        helper: helper,
        error: error,
        suffix: suffix,
        autofocus: autofocus,
        enabled: enabled,
        style: style,
        info: info,
        textAlign: textAlign,
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
        inputFormatters: [_numberChars],
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
}

/// Porcentaje (o puntos porcentuales con `suffix: 'pp'`).
class PercentField extends StatelessWidget {
  const PercentField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.error,
    this.suffix = '%',
    this.onChanged,
    this.textAlign = TextAlign.start,
  });
  final String label;
  final TextEditingController? controller;
  final String? helper, error;
  final String suffix;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => FaroTextField(
        label: label,
        controller: controller,
        helper: helper,
        error: error,
        suffix: suffix,
        textAlign: textAlign,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: [_numberChars],
        onChanged: onChanged,
      );
}

/// Participaciones, unidades, años, edades… (número sin unidad monetaria).
class UnitsField extends StatelessWidget {
  const UnitsField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.error,
    this.suffix,
    this.integer = false,
    this.onChanged,
  });
  final String label;
  final TextEditingController? controller;
  final String? helper, error, suffix;
  final bool integer;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => FaroTextField(
        label: label,
        controller: controller,
        helper: helper,
        error: error,
        suffix: suffix,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [integer ? FilteringTextInputFormatter.digitsOnly : _numberChars],
        onChanged: onChanged,
      );
}

/// Campo de fecha: un campo con icono que abre el calendario (nunca un chip suelto).
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.first,
    this.last,
    this.helper,
    this.emptyText = 'Elegir fecha',
    this.clearable = false,
    this.clearTooltip = 'Quitar la fecha',
    this.pickerHelp,
    this.yearFirst = false,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? first, last;
  final String? helper;
  final String emptyText;
  final bool clearable;
  final String clearTooltip;
  final String? pickerHelp;
  final bool yearFirst; // fechas lejanas (nacimiento): el calendario empieza eligiendo el año

  Future<void> _pick(BuildContext context) async {
    final lo = first ?? DateTime(2000);
    final hi = last ?? DateTime(2100);
    var initial = value ?? DateTime.now();
    if (initial.isBefore(lo)) initial = lo;
    if (initial.isAfter(hi)) initial = hi;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: lo,
      lastDate: hi,
      helpText: pickerHelp ?? label,
      initialDatePickerMode: yearFirst ? DatePickerMode.year : DatePickerMode.day,
    );
    if (d != null) onChanged(DateTime.utc(d.year, d.month, d.day));
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.sm),
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          suffixIcon: clearable && v != null
              ? IconButton(tooltip: clearTooltip, icon: const Icon(Icons.close), onPressed: () => onChanged(null))
              : const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(v == null ? emptyText : fullDate(v)),
      ),
    );
  }
}

/// Opción de un `SelectField`.
class SelectOption<T> {
  const SelectOption(this.value, this.label, {this.subtitle, this.icon, this.iconColor});
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
}

class Picked<T> {
  const Picked(this.value);
  final T value;
}

/// Selector: el texto elegido nunca se corta. Con más de [searchThreshold] opciones, el
/// selector trae buscador.
class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helper,
    this.emptyText = 'Elegir…',
    this.searchThreshold = 7,
    this.error,
  });
  final String label;
  final T? value;
  final List<SelectOption<T>> options;
  final ValueChanged<T>? onChanged;
  final String? helper, error;
  final String emptyText;
  final int searchThreshold;

  Future<void> _open(BuildContext context) async {
    final picked = await showSelectPicker<T>(context,
        title: label, options: options, selected: value, search: options.length > searchThreshold);
    if (picked != null) onChanged?.call(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final sel = options.where((o) => o.value == value).firstOrNull;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.sm),
      onTap: onChanged == null ? null : () => _open(context),
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          errorText: error,
          enabled: onChanged != null,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: sel == null
            ? Text(emptyText, style: TextStyle(color: Theme.of(context).hintColor))
            : Row(spacing: Space.sm, children: [
                if (sel.icon != null) Icon(sel.icon, size: 20, color: sel.iconColor),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sel.label),
                    if (sel.subtitle != null) Text(sel.subtitle!, style: tt.bodySmall),
                  ]),
                ),
              ]),
      ),
    );
  }
}

/// Lista de opciones para elegir una (hoja en el móvil, diálogo en pantallas anchas). `null` si
/// se cierra sin elegir.
Future<Picked<T>?> showSelectPicker<T>(
  BuildContext context, {
  required String title,
  required List<SelectOption<T>> options,
  T? selected,
  bool search = false,
}) {
  Widget body(BuildContext c) => _SelectPicker<T>(title: title, options: options, selected: selected, search: search);
  if (context.isCompact) {
    return showModalBottomSheet<Picked<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (c) => FractionallySizedBox(heightFactor: search ? 0.9 : null, child: body(c)),
    );
  }
  return showDialog<Picked<T>>(
    context: context,
    builder: (c) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: MediaQuery.sizeOf(c).height * 0.8),
        child: body(c),
      ),
    ),
  );
}

class _SelectPicker<T> extends StatefulWidget {
  const _SelectPicker({required this.title, required this.options, this.selected, this.search = false});
  final String title;
  final List<SelectOption<T>> options;
  final T? selected;
  final bool search;

  @override
  State<_SelectPicker<T>> createState() => _SelectPickerState<T>();
}

class _SelectPickerState<T> extends State<_SelectPicker<T>> {
  String _q = '';

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  @override
  Widget build(BuildContext context) {
    final q = _norm(_q.trim());
    final shown = q.isEmpty
        ? widget.options
        : widget.options.where((o) => _norm('${o.label} ${o.subtitle ?? ''}').contains(q)).toList();
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.sm),
        child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (widget.search)
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
          child: TextField(
            key: const Key('select-search'),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Buscar',
              prefixIcon: Icon(Icons.search),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
        ),
      Flexible(
        child: ListView(shrinkWrap: true, children: [
          for (final o in shown)
            ListTile(
              key: Key('option-${o.label}'),
              leading: o.icon == null ? null : Icon(o.icon, color: o.iconColor),
              title: Text(o.label),
              subtitle: o.subtitle == null ? null : Text(o.subtitle!),
              trailing: o.value == widget.selected ? const Icon(Icons.check) : null,
              selected: o.value == widget.selected,
              onTap: () => Navigator.pop(context, Picked<T>(o.value)),
            ),
          if (shown.isEmpty)
            const Padding(padding: EdgeInsets.all(Space.xl), child: Text('Nada coincide con la búsqueda')),
        ]),
      ),
      const SizedBox(height: Space.sm),
    ]);
  }
}

/// Segmento de un `SegmentedField`.
class Segment<T> {
  const Segment(this.value, this.label, {this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// 2–4 opciones excluyentes. Si los nombres no caben enteros, pasa a chips en varias líneas
/// (nunca se cortan). La elegida lleva una marca ✓, no solo otro color.
class SegmentedField<T> extends StatelessWidget {
  const SegmentedField({
    super.key,
    this.label,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.buttonKey,
  });
  final String? label;
  final List<Segment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final style = Theme.of(context).textTheme.labelLarge!;
        final painter = TextPainter(textDirection: TextDirection.ltr, textScaler: MediaQuery.textScalerOf(context));
        // Los segmentos miden todos lo mismo: cabe si el más largo cabe n veces
        var widest = 0.0;
        for (final s in segments) {
          painter.text = TextSpan(text: s.label, style: style);
          painter.layout();
          final w = painter.width + 30 + 34; // icono o ✓ de la elegida + márgenes
          if (w > widest) widest = w;
        }
        final fits = widest * segments.length <= box.maxWidth;
        final field = fits
            ? SegmentedButton<T>(
                key: buttonKey,
                segments: [
                  for (final s in segments)
                    ButtonSegment(value: s.value, label: Text(s.label), icon: s.icon == null ? null : Icon(s.icon)),
                ],
                selected: {value},
                onSelectionChanged: onChanged == null ? null : (v) => onChanged!(v.first),
              )
            : Wrap(key: buttonKey, spacing: Space.sm, runSpacing: Space.xs, children: [
                for (final s in segments)
                  ChoiceChip(
                    // Con icono, la ✓ del elegido lo sustituye (si no, se dibuja encima)
                    showCheckmark: s.icon == null,
                    avatar: s.icon == null ? null : Icon(s.value == value ? Icons.check : s.icon, size: 18),
                    label: Text(s.label),
                    selected: s.value == value,
                    onSelected: onChanged == null ? null : (_) => onChanged!(s.value),
                  ),
              ]);
        if (label == null) return field;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
          Text(label!, style: FaroText.caption(context)),
          field,
        ]);
      });
}

/// Más de 4 opciones excluyentes, como chips.
class ChoiceChipsField<T> extends StatelessWidget {
  const ChoiceChipsField({super.key, this.label, required this.options, required this.value, required this.onChanged});
  final String? label;
  final List<Segment<T>> options;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
        if (label != null) Text(label!, style: FaroText.caption(context)),
        Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
          for (final o in options)
            ChoiceChip(
              key: Key('choice-${o.label}'),
              showCheckmark: o.icon == null,
              avatar: o.icon == null ? null : Icon(o.value == value ? Icons.check : o.icon, size: 18),
              label: Text(o.label),
              selected: o.value == value,
              onSelected: onChanged == null ? null : (_) => onChanged!(o.value),
            ),
        ]),
      ]);
}

/// Interruptor con título y explicación.
class SwitchField extends StatelessWidget {
  const SwitchField({super.key, required this.title, this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        value: value,
        onChanged: onChanged,
      );
}

/// Bloque de campos con título opcional; separación `fieldGap` entre campos.
class FormSection extends StatelessWidget {
  const FormSection({super.key, this.title, this.subtitle, required this.children});
  final String? title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
        if (title != null)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title!, style: Theme.of(context).textTheme.titleSmall),
            if (subtitle != null) Text(subtitle!, style: FaroText.caption(context)),
          ]),
        ...children,
      ]);
}

/// Botones del formulario: secundarios a la izquierda del principal, todo alineado a la derecha.
class FormActions extends StatelessWidget {
  const FormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.busy = false,
    this.secondary = const [],
    this.primaryKey,
    this.expand = false,
  });
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool busy;
  final List<Widget> secondary;
  final Key? primaryKey;

  /// Botón principal a todo el ancho (hojas en el móvil).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final primary = FilledButton(
      key: primaryKey,
      onPressed: busy ? null : onPrimary,
      child: busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(primaryLabel),
    );
    if (expand) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
        if (secondary.isNotEmpty) Wrap(alignment: WrapAlignment.center, spacing: Space.sm, children: secondary),
        SizedBox(height: 48, child: primary),
      ]);
    }
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [...secondary, primary],
    );
  }
}

/// Abre un formulario: en el móvil, hoja a pantalla completa con asa; en pantallas anchas,
/// diálogo centrado (máx. 560 px) o, con [side], panel a la derecha. El contenido debería ser un
/// `FormPanel` (título, campos y botones fijos abajo).
Future<T?> showFormPanel<T>(BuildContext context, {required WidgetBuilder builder, bool side = false}) {
  if (context.isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true, // por encima de la barra inferior
      showDragHandle: true,
      builder: (c) => FractionallySizedBox(heightFactor: 1, child: builder(c)),
    );
  }
  if (side) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      transitionDuration: Durations.medium2,
      pageBuilder: (c, _, _) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 3,
          child: SizedBox(width: 480, height: double.infinity, child: SafeArea(child: builder(c))),
        ),
      ),
      transitionBuilder: (c, a, _, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (c) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: FaroLayout.formPanel, maxHeight: MediaQuery.sizeOf(c).height * 0.9),
        child: builder(c),
      ),
    ),
  );
}

/// Contenido de un `showFormPanel`: cabecera con título y cerrar, campos con scroll y botones
/// fijos abajo (por encima del teclado). Enter en un campo de una línea y Ctrl+Enter guardan.
class FormPanel extends StatelessWidget {
  const FormPanel({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.onSubmit,
    this.header,
  });
  final String title;
  final List<Widget> children;
  final Widget? actions;
  final VoidCallback? onSubmit;

  /// Algo fijo bajo el título (p. ej. el tipo de operación).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    final pad = compact ? Space.lg : Space.xl;
    final body = Column(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, compact ? 0 : Space.lg, Space.sm, Space.sm),
          child: Row(children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
              tooltip: 'Cerrar',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.maybePop(context),
            ),
          ]),
        ),
        if (header case final h?) Padding(padding: EdgeInsets.fromLTRB(pad, 0, pad, Space.md), child: h),
        Flexible(
          fit: compact ? FlexFit.tight : FlexFit.loose,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, Space.sm, pad, Space.lg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: children),
          ),
        ),
        if (actions != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6))),
            ),
            child: Padding(padding: EdgeInsets.fromLTRB(pad, Space.md, pad, Space.md), child: actions),
          ),
      ],
    );
    return FormSubmitScope(
      onSubmit: onSubmit,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, control: true): ?onSubmit,
        },
        child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: body),
      ),
    );
  }
}
