import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' as gastos show accountsProvider, refreshGastos, showSnack;
import 'data.dart';

/// Redondeo de las órdenes al repartir: 0 = sin redondear (al céntimo); 1, 5 o 10 € = cada orden
/// en múltiplos de ese importe (la suma no cambia). Se recuerda en el dispositivo.
class ContributionRoundController extends Notifier<int> {
  static const _key = 'faro.contribution.round';
  final _storage = const FlutterSecureStorage();

  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    try {
      final v = int.tryParse(await _storage.read(key: _key) ?? '');
      if (v != null && v != state) state = v;
    } catch (_) {}
  }

  Future<void> set(int v) async {
    state = v;
    try {
      await _storage.write(key: _key, value: '$v');
    } catch (_) {}
  }
}

final contributionRoundProvider = NotifierProvider<ContributionRoundController, int>(ContributionRoundController.new);

/// Motor de aportaciones: reparte un importe según la distancia de cada activo a su objetivo
/// (solo compras). Las órdenes se pueden retocar antes de generarlas.
class ContributionPage extends ConsumerStatefulWidget {
  const ContributionPage({super.key});

  @override
  ConsumerState<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends ConsumerState<ContributionPage> {
  final _amount = TextEditingController();
  ContributionOut? _result;
  final _edits = <String, TextEditingController>{};
  DateTime _date = DateTime.now();
  bool _fromGastos = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = ref.read(invSettingsProvider).value;
    if (s?.monthlyContribution != null) {
      _amount.text = dec(s!.monthlyContribution).toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    for (final c in _edits.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _calc([int? round]) async {
    final int unit = round ?? ref.read(contributionRoundProvider);
    final v = parseEsDecimal(_amount.text);
    if (v == null || v <= Decimal.zero) return setState(() => _error = 'Introduce un importe');
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r =
          (await ref.read(apiProvider).getInversionesApi().suggest(
            suggestIn: SuggestIn(amount: apiAmount(v), roundTo: unit > 0 ? '$unit' : null),
          )).data!;
      for (final c in _edits.values) {
        c.dispose();
      }
      _edits
        ..clear()
        ..addAll({
          for (final o in r.orders)
            o.assetId: TextEditingController(text: dec(o.amount).toStringAsFixed(2).replaceAll('.', ',')),
        });
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generate() async {
    final orders = [
      for (final o in _result!.orders)
        if ((parseEsDecimal(_edits[o.assetId]!.text) ?? Decimal.zero) > Decimal.zero)
          OrderIn(assetId: o.assetId, amount: apiAmount(parseEsDecimal(_edits[o.assetId]!.text)!)),
    ];
    if (orders.isEmpty) return;
    final gastosAccount = _fromGastos
        ? (ref.read(gastos.accountsProvider).value ?? const <AccountOut>[])
              .where((a) => a.kind.value == 'gastos')
              .firstOrNull
        : null;
    setState(() => _busy = true);
    try {
      await ref
          .read(apiProvider)
          .getInversionesApi()
          .createOrders(
            ordersIn: OrdersIn(
              orders: orders,
              tradeDate: DateTime.utc(_date.year, _date.month, _date.day),
              fromAccountId: gastosAccount?.id,
            ),
          );
      refreshInv(ref);
      gastos.refreshGastos(ref);
      if (!mounted) return;
      gastos.showSnack(context, '${orders.length} órdenes anotadas como pendientes de VL');
      Navigator.of(context).maybePop();
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final classes = {for (final c in ref.watch(assetClassesProvider).value ?? const <AssetClassOut>[]) c.id: c.name};
    final r = _result;
    final total = r == null
        ? Decimal.zero
        : _edits.values.fold(Decimal.zero, (a, c) => a + (parseEsDecimal(c.text) ?? Decimal.zero));
    final round = ref.watch(contributionRoundProvider);
    void setRound(int v) {
      ref.read(contributionRoundProvider.notifier).set(v);
      if (_result != null) _calc(v);
    }

    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Repartir una aportación')),
      body: FormListView(
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: MoneyField(
                  key: const Key('contribution-amount'),
                  label: '¿Cuánto vas a aportar?',
                  controller: _amount,
                  onSubmitted: (_) => _calc(),
                ),
              ),
              FilledButton(
                key: const Key('calc-contribution'),
                onPressed: _busy ? null : _calc,
                child: const Text('Calcular'),
              ),
            ],
          ),
          SwitchField(
            key: const Key('round-orders'),
            title: 'Redondear las órdenes',
            subtitle: 'Importes sin céntimos. La suma no cambia.',
            value: round > 0,
            onChanged: (v) => setRound(v ? 1 : 0),
          ),
          if (round > 0)
            Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
              Row(children: [
                Flexible(child: Text('Cada orden, en múltiplos de', style: FaroText.caption(context))),
                const InfoTip(
                  '',
                  title: 'Redondear las órdenes',
                  text: 'Cada orden se redondea al múltiplo elegido con el mismo reparto (mayor resto), así que '
                      'la suma no cambia. Si el importe no es múltiplo, lo que sobra va a la orden mayor.',
                ),
              ]),
              SegmentedField<int>(
                buttonKey: const Key('round-unit'),
                segments: const [Segment(1, '1 €'), Segment(5, '5 €'), Segment(10, '10 €')],
                value: round,
                onChanged: setRound,
              ),
            ]),
          ErrorText(_error),
          if (r != null) ...[
            const SizedBox(height: 16),
            Text('Por categoría', style: tt.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                for (final c in r.byClass) Chip(label: Text('${classes[c.assetClassId] ?? '—'} ${eur(c.amount)}')),
              ],
            ),
            if (dec(r.unassigned).sign > 0)
              Text('${eur(r.unassigned)} sin repartir: hay categorías con objetivo pero sin activos con objetivo.'),
            const SizedBox(height: 12),
            Text('Órdenes', style: tt.titleMedium),
            for (final o in r.orders)
              FieldRow(minWidth: 120, flex: const [3, 2], children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.assetName, style: tt.bodyLarge),
                  Text(
                    o.approxUnits != null
                        ? '≈ ${qty(o.approxUnits)}${nbsp}part. a ${eur(o.price)} (último precio)'
                        : 'Sin precio conocido',
                    style: tt.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ]),
                MoneyField(
                  key: Key('order-${o.assetId}'),
                  label: 'Importe',
                  textAlign: TextAlign.end,
                  controller: _edits[o.assetId],
                  onChanged: (_) => setState(() {}),
                ),
              ]),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Total')),
                Text(formatEur(total), style: tt.titleMedium),
              ],
            ),
            DateField(
              key: const Key('contribution-date'),
              label: 'Fecha de la orden',
              value: _date,
              first: DateTime(2000),
              last: DateTime.now().add(const Duration(days: 30)),
              onChanged: (d) => setState(() => _date = d ?? _date),
            ),
            SwitchField(
              title: 'Sale de mi cuenta de gastos',
              subtitle: 'Anota la transferencia como prevista en tu ciclo (no cuenta como gasto).',
              value: _fromGastos,
              onChanged: (v) => setState(() => _fromGastos = v),
            ),
            FilledButton.icon(
              key: const Key('generate-orders'),
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Generar órdenes'),
              onPressed: _busy ? null : _generate,
            ),
            const Text(
              'Quedan como pendientes de valor liquidativo. Las órdenes las haces tú en tu broker; '
              'Fanal no se conecta a él.',
            ),
          ],
          const NoAdviceNote(
            text:
                'Reparto calculado con tus objetivos: lleva cada activo hacia su peso objetivo y nunca '
                'propone vender. Es un cálculo, no una recomendación de inversión.',
          ),
        ],
      ),
    );
  }
}
