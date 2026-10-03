import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show pct, NoAdviceNote;
import 'data.dart';

/// Revisión trimestral: cómo fue el trimestre frente al anterior, cómo va el plan y qué decides.
class ReviewTab extends ConsumerStatefulWidget {
  const ReviewTab({super.key});

  @override
  ConsumerState<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends ConsumerState<ReviewTab> {
  String? _quarter;

  @override
  Widget build(BuildContext context) {
    final qs = ref.watch(quartersProvider);
    return qs.when(
      loading: () => const SkeletonPage(),
      error: (e, _) => Center(child: Text(apiErrorMessage(e))),
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('Todavía no hay datos para revisar.'));
        // Por defecto, el último trimestre terminado
        final quarter = _quarter ?? items.firstWhere((q) => !q.inProgress, orElse: () => items.first).quarter;
        final pending = items.where((q) => !q.inProgress && !q.saved).firstOrNull;
        return FormListView(children: [
          if (pending != null && pending.quarter == items.firstWhere((q) => !q.inProgress).quarter)
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text('Te toca la revisión del ${pending.label}'),
                subtitle: const Text('Mira cómo fue el trimestre y apunta qué cambia.'),
              ),
            ),
          SelectField<String>(
            key: const Key('review-quarter'),
            label: 'Trimestre',
            value: quarter,
            options: [
              for (final q in items)
                SelectOption(q.quarter, q.label,
                    subtitle: _quarterNote(q)),
            ],
            onChanged: (v) => setState(() => _quarter = v),
          ),
          _ReviewBody(key: ValueKey(quarter), quarter: quarter),
        ]);
      },
    );
  }
}

class _ReviewBody extends ConsumerStatefulWidget {
  const _ReviewBody({super.key, required this.quarter});
  final String quarter;

  @override
  ConsumerState<_ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends ConsumerState<_ReviewBody> {
  final _changed = TextEditingController();
  final _next = TextEditingController();
  bool _filled = false;
  bool _busy = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).getPlanesApi().saveReview(
            quarter: widget.quarter,
            quarterReviewIn: QuarterReviewIn(changed: _changed.text, nextSteps: _next.text),
          );
      ref.invalidate(quartersProvider);
      ref.invalidate(reviewProvider(widget.quarter));
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(reviewProvider(widget.quarter));
    return r.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text(apiErrorMessage(e)),
      data: (rv) {
        if (!_filled) {
          _changed.text = rv.changed;
          _next.text = rv.nextSteps;
          _filled = true;
        }
        final m = rv.metrics, p = rv.previous;
        final tt = Theme.of(context).textTheme;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
          if (rv.inProgress)
            Text('El trimestre aún no ha terminado: las cifras pueden cambiar.', style: tt.bodySmall),
          _Section(
            title: 'Ahorro',
            subtitle: m.cycles == 0
                ? 'Sin ciclos cerrados en el trimestre'
                : '${m.cycles} ${m.cycles == 1 ? 'ciclo cerrado' : 'ciclos cerrados'}'
                    '${p != null ? ' · comparado con el ${rv.previousLabel}' : ''}',
            rows: [
              _Row('Ingresos', eur(m.income), delta: _money(m.income, p?.income)),
              _Row('Gasto', eur(m.spend), delta: _money(m.spend, p?.spend, upIsGood: false)),
              _Row('Te sobró', eur(m.surplus), delta: _money(m.surplus, p?.surplus), bold: true),
              _Row('Tasa de ahorro', pct(m.savingsRate, decimals: 0), delta: _points(m.savingsRate, p?.savingsRate)),
              _Row('Fijos y cuotas (media por ciclo)', m.fixedAvg == null ? '—' : eur(m.fixedAvg!),
                  delta: _money(m.fixedAvg, p?.fixedAvg, upIsGood: false)),
            ],
          ),
          if (rv.rising.isNotEmpty)
            _Section(
              title: 'Lo que más subió',
              rows: [
                for (final c in rv.rising)
                  _Row(c.name, eur(c.amount), delta: _money(c.amount, c.previous, upIsGood: false)),
              ],
            ),
          _Section(
            title: 'Cartera',
            rows: [
              _Row('Valor al final', eur(m.portfolioEnd)),
              _Row('Aportado en el trimestre', eur(m.contributed)),
              _Row('Ganancia del trimestre', eur(m.gain, plus: true), good: _sign(m.gain)),
              _Row('Rentabilidad (TWR)', pct(m.twr, plus: true), good: m.twr == null ? null : _sign(m.twr!),
                  delta: p?.twr == null ? null : _Delta('${rv.previousLabel}: ${pct(p!.twr, plus: true)}', null)),
            ],
          ),
          _Section(
            title: 'Patrimonio (cuentas + inversiones)',
            rows: [
              _Row('Al empezar', eur(m.networthStart)),
              _Row('Al terminar', eur(m.networthEnd),
                  delta: _money(m.networthEnd, m.networthStart), bold: true),
            ],
          ),
          _Section(
            title: 'Plan',
            subtitle: rv.savedAt == null ? 'Estado de hoy' : 'Estado cuando guardaste la revisión',
            rows: [
              if (m.fireNeeded != null) _Row('Necesitas (euros de hoy)', eur(m.fireNeeded!)),
              if (m.fireProgress != null) _Row('Llevas', pct(m.fireProgress, decimals: 1)),
              if (m.fireNeeded != null)
                _Row('Al ritmo de entonces llegas con', ageText(m.fireAge),
                    delta: p?.fireAge == null ? null : _Delta('antes ${ageText(p!.fireAge)}', _ageGood(m.fireAge, p.fireAge))),
              if (m.fireNeeded == null) const _Row('Independencia financiera', 'Configúrala en la pestaña Independencia'),
              _Row('Cartera fuera de rango', m.outOfRange.isEmpty ? 'Nada' : m.outOfRange.join(' · ')),
              for (final g in m.goals)
                _Row(g.name, g.progress == null ? '—' : pct(g.progress, decimals: 0),
                    good: g.onTrack),
            ],
          ),
          FaroTextField(
            key: const Key('review-changed'),
            label: '¿Qué ha cambiado este trimestre?',
            controller: _changed,
            minLines: 2,
            maxLines: 6,
          ),
          FaroTextField(
            key: const Key('review-next'),
            label: '¿Qué vas a hacer distinto el próximo?',
            controller: _next,
            minLines: 2,
            maxLines: 6,
          ),
          if (_error != null) ErrorText(_error),
          FilledButton(
            key: const Key('review-save'),
            onPressed: _busy ? null : _save,
            child: Text(rv.savedAt == null ? 'Guardar revisión' : 'Actualizar revisión'),
          ),
          if (rv.savedAt != null)
            Text('Guardada el ${MaterialLocalizations.of(context).formatShortDate(rv.savedAt!.toLocal())}. '
                'Al guardar se toma una foto de estas cifras para compararlas el trimestre que viene.',
                style: tt.bodySmall),
          const NoAdviceNote(),
        ]);
      },
    );
  }
}

// --- Piezas -----------------------------------------------------------------------------------------
/// Cambio frente al trimestre anterior. [good]: si va en la buena dirección (null = neutro). Se ve
/// con color **e** icono (✓ o aviso), nunca solo con color.
class _Delta {
  const _Delta(this.text, this.good);
  final String text;
  final bool? good;
}

bool _sign(String v) => dec(v) >= Decimal.zero;

/// Diferencia en euros frente al trimestre anterior; verde si va en la buena dirección.
_Delta? _money(String? now, String? before, {bool upIsGood = true}) {
  if (now == null || before == null) return null;
  final d = dec(now) - dec(before);
  if (d == Decimal.zero) return const _Delta('igual', null);
  final good = (d > Decimal.zero) == upIsGood;
  return _Delta(eur(d.toString(), plus: true), good);
}

/// Diferencia en puntos porcentuales (tasas).
_Delta? _points(String? now, String? before) {
  if (now == null || before == null) return null;
  final d = (dec(now) - dec(before)) * Decimal.fromInt(100);
  final s = withMinus(d.toStringAsFixed(1).replaceAll('.', ','));
  return _Delta('${d > Decimal.zero ? '+' : ''}$s pp', d == Decimal.zero ? null : d > Decimal.zero);
}

/// Llegar antes es bueno.
bool? _ageGood(String? now, String? before) {
  if (now == null || before == null) return null;
  final d = dec(now) - dec(before);
  return d == Decimal.zero ? null : d < Decimal.zero;
}

class _Row {
  const _Row(this.label, this.value, {this.delta, this.good, this.bold = false});
  final String label;
  final String value;
  final _Delta? delta;
  final bool? good; // el valor en sí: ganancia/pérdida, objetivo en camino o no
  final bool bold;
}

/// Texto con color e icono de "bien" (✓) o "mal" (aviso); sin [good], tal cual.
class _Judged extends StatelessWidget {
  const _Judged(this.text, this.good, {this.style});
  final String text;
  final bool? good;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final g = good;
    if (g == null) return Text(text, textAlign: TextAlign.end, style: style);
    final color = g ? context.faro.gain : context.faro.loss;
    final size = (style?.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14) + 2;
    return Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: [
      Icon(g ? Icons.check_circle_outline : Icons.warning_amber_rounded, size: size, color: color,
          semanticLabel: g ? 'bien' : 'a vigilar'),
      Flexible(child: Text(text, textAlign: TextAlign.end, style: (style ?? const TextStyle()).copyWith(color: color))),
    ]);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.subtitle, required this.rows});
  final String title;
  final String? subtitle;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: tt.titleMedium),
          if (subtitle != null) Text(subtitle!, style: tt.bodySmall),
          const SizedBox(height: 6),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(r.label)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _Judged(r.value, r.good, style: TextStyle(fontWeight: r.bold ? FontWeight.w600 : null)),
                  if (r.delta != null) _Judged(r.delta!.text, r.delta!.good, style: tt.bodySmall),
                ]),
              ]),
            ),
        ]),
      ),
    );
  }
}

String? _quarterNote(QuarterItemOut q) {
  final t = [if (q.inProgress) 'en curso', if (q.saved) 'revisado'].join(' · ');
  return t.isEmpty ? null : t;
}
