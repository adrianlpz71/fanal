import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../gastos/data.dart' show showSnack, shortDate;
import '../patrimonio/data.dart';
import 'data.dart';

const _dims = {
  'region': 'Región',
  'pais': 'País / zona',
  'sector': 'Sector',
  'divisa': 'Divisa',
  'plataforma': 'Plataforma',
  'tipo': 'Tipo',
};

/// Exposición de la cartera: cada posición pesa por su valor; los fondos se miran por dentro
/// (composición de FT o la que pongas a mano).
class ExposurePage extends ConsumerStatefulWidget {
  const ExposurePage({super.key});

  @override
  ConsumerState<ExposurePage> createState() => _ExposurePageState();
}

class _ExposurePageState extends ConsumerState<ExposurePage> {
  String _dim = 'region';
  bool _busy = false;

  List<ExposureItemOut> _items(ExposureOut e) => switch (_dim) {
        'region' => e.region,
        'pais' => e.pais,
        'sector' => e.sector,
        'divisa' => e.divisa,
        'plataforma' => e.plataforma,
        _ => e.tipo,
      };

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      final r = (await ref.read(apiProvider).getAnalyticsApi().refreshExposure()).data!;
      refreshAnalytics(ref);
      if (mounted) {
        showSnack(context, r.errors.isEmpty ? 'Composición actualizada (${r.updated} fondos)' : r.errors.join('; '));
      }
    } catch (e) {
      if (mounted) showSnack(context, apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = ref.watch(exposureProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Exposición'), actions: [
        IconButton(
          tooltip: 'Actualizar la composición de los fondos',
          icon: _busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
          onPressed: _busy ? null : _refresh,
        ),
      ]),
      body: e.when(
        loading: () => const SkeletonPage(),
        error: (err, _) => Center(child: Text(apiErrorMessage(err))),
        data: (ex) {
          final items = _items(ex);
          final cs = Theme.of(context).colorScheme;
          return ListView(padding: const EdgeInsets.all(12), children: [
            ChoiceChipsField<String>(
              options: [for (final d in _dims.entries) Segment(d.key, d.value)],
              value: _dim,
              onChanged: (v) => setState(() => _dim = v),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty) const ListTile(title: Text('Sin posiciones')),
            for (final it in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(it.key)),
                    Text('${pct(it.weight, decimals: 1)} · ${eur(it.value)}'),
                  ]),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: dec(it.weight).toDouble().clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: it.key.startsWith('Sin datos') || it.key.startsWith('Otros') ? cs.outline : cs.primary,
                  ),
                ]),
              ),
            const NoAdviceNote(
              text: 'Los fondos se miran por dentro con la composición de FT. Es un cálculo, no un consejo.',
              infoTitle: 'Cómo se calcula',
              info: 'Cada posición pesa por su valor. La composición de los fondos la publica FT y se actualiza '
                  'cada semana; puedes corregirla en el detalle de cada activo → Composición. "Divisa" es la de '
                  'cotización del activo, no la de lo que hay dentro del fondo.',
            ),
          ]);
        },
      ),
    );
  }
}

/// Composición de un activo (automática y manual) con editor manual.
Future<void> showCompositionDialog(BuildContext context, WidgetRef ref, AssetOut a) async {
  final current = (await ref.read(apiProvider).getAnalyticsApi().getAssetExposure(assetId: a.id)).data ?? const [];
  if (!context.mounted) return;
  final manual = current.where((x) => x.source_ == 'manual').toList();
  final rows = [
    for (final x in manual) _Row(x.dimension, x.key, (dec(x.weight) * dec('100')).toString().replaceAll('.', ',')),
  ];
  final auto = current.where((x) => x.source_ == 'auto').toList();
  final res = await showFormPanel<bool>(context, builder: (_) => _CompositionForm(asset: a, auto: auto, rows: rows));
  if (res != true) return;
  try {
    await ref.read(apiProvider).getAnalyticsApi().putAssetExposure(assetId: a.id, assetExposureIn: [
      for (final r in rows)
        if (r.key.trim().isNotEmpty && fractionFromPct(r.pct) != null)
          AssetExposureIn(
            dimension: AssetExposureInDimensionEnum.values.firstWhere((d) => d.value == r.dim),
            key: r.key.trim(),
            weight: fractionFromPct(r.pct)!,
          ),
    ]);
    refreshAnalytics(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

class _Row {
  _Row(this.dim, this.key, this.pct);
  String dim;
  String key;
  String pct;
}

const _manualDims = [
  SelectOption('region', 'Región'),
  SelectOption('pais', 'País'),
  SelectOption('sector', 'Sector'),
];

/// Editor de la composición manual: cambia las filas de [rows] y cierra con `true` al guardar.
class _CompositionForm extends StatefulWidget {
  const _CompositionForm({required this.asset, required this.auto, required this.rows});
  final AssetOut asset;
  final List<AssetExposureOut> auto;
  final List<_Row> rows;

  @override
  State<_CompositionForm> createState() => _CompositionFormState();
}

class _CompositionFormState extends State<_CompositionForm> {
  final _ctrl = <_Row, (TextEditingController, TextEditingController)>{};

  (TextEditingController, TextEditingController) _of(_Row r) =>
      _ctrl.putIfAbsent(r, () => (TextEditingController(text: r.key), TextEditingController(text: r.pct)));

  @override
  void dispose() {
    for (final (k, p) in _ctrl.values) {
      k.dispose();
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final auto = widget.auto;
    void save() => Navigator.pop(context, true);
    return FormPanel(
      title: 'Composición · ${widget.asset.name}',
      onSubmit: save,
      actions: FormActions(primaryLabel: 'Guardar', onPrimary: save, expand: context.isCompact),
      children: [
        if (auto.isNotEmpty)
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Automática (FT, ${shortDate(auto.first.asOf)})', style: tt.titleSmall),
            Text([
              for (final x in auto.where((x) => x.dimension == 'region')) '${x.key} ${pct(x.weight, decimals: 1)}',
            ].join(' · ')),
          ]),
        Text('Manual (sustituye a la automática en esa dimensión)', style: tt.titleSmall),
        for (final r in widget.rows)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: FieldRow(minWidth: 120, children: [
                SelectField<String>(
                  label: 'Dimensión',
                  value: r.dim,
                  options: _manualDims,
                  onChanged: (v) => setState(() => r.dim = v),
                ),
                FaroTextField(label: 'Nombre', controller: _of(r).$1, onChanged: (v) => r.key = v),
                PercentField(label: 'Peso', controller: _of(r).$2, onChanged: (v) => r.pct = v),
              ]),
            ),
            IconButton(
              tooltip: 'Quitar',
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => widget.rows.remove(r)),
            ),
          ]),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Añadir'),
            onPressed: () => setState(() => widget.rows.add(_Row('pais', '', ''))),
          ),
        ),
      ],
    );
  }
}
