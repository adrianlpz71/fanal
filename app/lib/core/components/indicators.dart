import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../money.dart';
import '../tokens.dart';
import 'glossary.dart';

/// Importe con el formato de Faro: cifras tabulares, modo privacidad, signo y color opcionales
/// (siempre con icono si lleva color) y modo compacto (sin céntimos a partir de 10.000 €).
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.plus = false,
    this.colored = false,
    this.compact = false,
    this.textAlign,
  });

  /// Desde un importe de la API ("1234.56").
  MoneyText.api(String? s, {Key? key, TextStyle? style, bool plus = false, bool colored = false, bool compact = false})
      : this(dec(s), key: key, style: style, plus: plus, colored: colored, compact: compact);

  final Decimal amount;
  final TextStyle? style;
  final bool plus;
  final bool colored;
  final bool compact;
  final TextAlign? textAlign;

  /// Texto del importe (también para tooltips y semántica).
  static String format(Decimal amount, {bool plus = false, bool compact = false}) {
    final big = compact && amount.abs() >= Decimal.fromInt(10000);
    return formatEur(amount, showPlus: plus, decimals: big ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(fontFeatures: FaroText.tabular);
    final text = format(amount, plus: plus, compact: compact);
    if (!colored || amount == Decimal.zero || privacyMode) {
      return Text(text, style: base, textAlign: textAlign, softWrap: false);
    }
    final up = amount > Decimal.zero;
    final color = up ? context.faro.gain : context.faro.loss;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: (base.fontSize ?? 14) + 6),
      Flexible(child: Text(text, style: base.copyWith(color: color), textAlign: textAlign)),
    ]);
  }
}

/// Porcentaje con color e icono (variaciones, rentabilidades). `fraction` en tanto por uno.
class DeltaText extends StatelessWidget {
  const DeltaText(this.fraction, {super.key, this.style, this.decimals = 2, this.suffix = ''});
  final Decimal? fraction;
  final TextStyle? style;
  final int decimals;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(fontFeatures: FaroText.tabular);
    final f = fraction;
    if (f == null) return Text('—', style: base);
    final v = f * Decimal.fromInt(100);
    final s = '${v > Decimal.zero ? '+' : ''}${withMinus(v.toStringAsFixed(decimals).replaceAll('.', ','))} %$suffix';
    if (v == Decimal.zero) return Text(s, style: base);
    final up = v > Decimal.zero;
    final color = up ? context.faro.gain : context.faro.loss;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: (base.fontSize ?? 14) + 6),
      Flexible(child: Text(s, style: base.copyWith(color: color))),
    ]);
  }
}

/// Estados con un vocabulario único: texto claro + icono + color.
enum PillTone { ok, below, above, info, warning, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone = PillTone.neutral, this.tooltip});
  final String label;
  final PillTone tone;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final f = context.faro;
    final cs = Theme.of(context).colorScheme;
    final (Color fg, Color bg, IconData icon) = switch (tone) {
      PillTone.ok => (f.gain, f.gainContainer, Icons.check_circle_outline),
      PillTone.below => (f.info, f.infoContainer, Icons.south_east),
      PillTone.above => (f.warning, f.warningContainer, Icons.north_east),
      PillTone.info => (f.info, f.infoContainer, Icons.info_outline),
      PillTone.warning => (f.warning, f.warningContainer, Icons.warning_amber_rounded),
      PillTone.neutral => (cs.onSurfaceVariant, cs.surfaceContainerHighest, Icons.circle_outlined),
    };
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, spacing: Space.xs, children: [
        Icon(icon, size: 14, color: fg),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
        ),
      ]),
    );
    return tooltip == null ? pill : Tooltip(message: tooltip!, child: pill);
  }
}

/// ⓘ con la definición del glosario (o un texto propio). En web sale al pasar el ratón; en el
/// móvil, al tocar se abre un diálogo.
class InfoTip extends StatelessWidget {
  const InfoTip(this.termKey, {super.key, this.title, this.text, this.size = 18});

  /// Clave del glosario (`glossary`). Si no existe, se usan [title] y [text].
  final String termKey;
  final String? title;
  final String? text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final e = glossary[termKey];
    final t = title ?? e?.term ?? '';
    final body = text ?? e?.text ?? '';
    return Tooltip(
      message: body,
      child: IconButton(
        tooltip: null,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        iconSize: size,
        icon: Icon(Icons.info_outline, semanticLabel: 'Qué es $t'),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(t),
            content: Text(body),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Entendido'))],
          ),
        ),
      ),
    );
  }
}

/// KPI: etiqueta (con ⓘ opcional), valor grande, variación y una nota. Si no hay dato todavía,
/// [unavailable] explica por qué (nunca un "—" a secas).
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    this.value,
    this.valueText,
    this.delta,
    this.note,
    this.info,
    this.unavailable,
    this.onTap,
    this.emphasis = false,
  });

  final String label;
  final Widget? value;
  final String? valueText;
  final Widget? delta;
  final String? note;
  final String? info; // clave del glosario
  final String? unavailable;
  final VoidCallback? onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final kpi = FaroText.kpi(context);
    return Card(
      margin: EdgeInsets.zero,
      color: emphasis ? cs.primaryContainer.withValues(alpha: 0.45) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.md, Space.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.xs, children: [
            Row(children: [
              Expanded(child: Text(label, style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant))),
              if (info != null) InfoTip(info!, size: 16),
            ]),
            if (unavailable != null)
              Text(unavailable!, style: FaroText.caption(context))
            else
              DefaultTextStyle.merge(
                style: kpi,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: value ?? Text(valueText ?? '—'),
                ),
              ),
            ?delta,
            if (note != null) Text(note!, style: FaroText.caption(context)),
          ]),
        ),
      ),
    );
  }
}

/// Rejilla de KPI: 2 columnas en el móvil y tantas como quepan (mín. 200 px) en pantallas anchas.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children, this.minWidth = 200});
  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final fit = ((box.maxWidth + Space.md) ~/ (minWidth + Space.md)).clamp(2, 6);
        // Filas equilibradas: 7 tarjetas en 4 + 3, no en 5 + 2 (ni una sola en la última fila)
        final rows = (children.length / fit).ceil();
        final cols = rows <= 1 ? fit : (children.length / rows).ceil().clamp(2, fit);
        final w = (box.maxWidth - Space.md * (cols - 1)) / cols;
        // Si en la última fila queda una sola tarjeta (7 en dos columnas), ocupa todo el ancho
        final n = children.length;
        final lone = rows > 1 && n % cols == 1;
        return Wrap(spacing: Space.md, runSpacing: Space.md, children: [
          for (final (i, c) in children.indexed) SizedBox(width: lone && i == n - 1 ? box.maxWidth : w, child: c),
        ]);
      });
}
