import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show showSnack;
import 'data.dart';

/// Objetivos en dos niveles: peso de cada categoría (con mínimo y máximo) y reparto dentro de cada
/// una. En el reparto se pueden añadir activos, quitarlos y archivar los que no tienen posición.
/// Cada guardado crea una versión nueva (el historial se conserva).
class TargetsPage extends ConsumerStatefulWidget {
  const TargetsPage({super.key});

  @override
  ConsumerState<TargetsPage> createState() => _TargetsPageState();
}

class _Macro {
  _Macro(String t, String lo, String hi, String tol)
      : target = TextEditingController(text: t),
        min = TextEditingController(text: lo),
        max = TextEditingController(text: hi),
        tol = TextEditingController(text: tol);
  final TextEditingController target, min, max, tol;
}

class _TargetsPageState extends ConsumerState<TargetsPage> {
  final _macro = <String, _Macro>{};
  final _inner = <String, TextEditingController>{};
  final _listed = <String, List<String>>{}; // categoría → activos en el reparto (en orden)
  final _archive = <String>{}; // activos que se archivan al guardar
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  String _p(String? f) => f == null ? '' : (dec(f) * Decimal.fromInt(100)).toString().replaceAll('.', ',');

  void _load(List<AssetClassOut> classes, List<AssetOut> assets, TargetsOut t, Map<String, PositionOut> pos) {
    final m = {for (final x in t.macro) x.assetClassId: x};
    final a = {for (final x in t.assets) x.assetId: x};
    for (final c in classes) {
      final x = m[c.id];
      _macro[c.id] = _Macro(_p(x?.target), _p(x?.min), _p(x?.max),
          (x?.tolerancePp ?? c.defaultTolerancePp).replaceAll('.', ','));
      // En el reparto: los que tienen objetivo o dinero; el resto se añade con "Añadir activo"
      _listed[c.id] = [
        for (final as in assets.where((x) => x.assetClassId == c.id && !x.watchlist && !x.archived))
          if (a[as.id] != null || _hasMoney(pos[as.id])) as.id,
      ];
    }
    for (final as in assets) {
      _inner[as.id] = TextEditingController(text: _p(a[as.id]?.target));
    }
    _archive.clear();
    _loaded = true;
  }

  static bool _hasMoney(PositionOut? p) =>
      p != null && (dec(p.units) > Decimal.zero || dec(p.pending) > Decimal.zero);

  Decimal _num(TextEditingController c) => parseEsDecimal(c.text) ?? Decimal.zero;

  String _fmt(Decimal d) => d.toString().replaceAll('.', ',');

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final macro = [
        for (final e in _macro.entries)
          if (e.value.target.text.trim().isNotEmpty)
            MacroTargetIn(
              assetClassId: e.key,
              target: fractionFromPct(e.value.target.text)!,
              min: fractionFromPct(e.value.min.text.isEmpty ? e.value.target.text : e.value.min.text),
              max: fractionFromPct(e.value.max.text.isEmpty ? e.value.target.text : e.value.max.text),
              tolerancePp: parseEsDecimal(e.value.tol.text)?.toString(),
            ),
      ];
      final inner = [
        for (final ids in _listed.values)
          for (final id in ids)
            if (_inner[id]!.text.trim().isNotEmpty) AssetTargetIn(assetId: id, target: fractionFromPct(_inner[id]!.text)!),
      ];
      final api = ref.read(apiProvider).getInversionesApi();
      await api.putTargets(targetsIn: TargetsIn(macro: macro, assets: inner));
      // Después de guardar el reparto sin ellos: se archivan (o se borran si no tienen operaciones)
      for (final id in _archive) {
        await api.deleteAsset(assetId: id);
      }
      refreshInv(ref);
      setState(() => _loaded = false);
      if (mounted) showSnack(context, 'Objetivos guardados');
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add(AssetClassOut c, List<AssetOut> assets) async {
    final listed = _listed[c.id]!;
    final candidates = assets
        .where((a) => a.assetClassId == c.id && !a.archived && !a.watchlist && !listed.contains(a.id) && !_archive.contains(a.id))
        .toList();
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Añadir a ${c.name}'),
        children: [
          for (final a in candidates)
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, a.id), child: Text(a.name)),
          if (candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('No hay más activos en esta categoría.'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, '__new__'),
            child: const Row(spacing: 8, children: [Icon(Icons.add, size: 20), Text('Dar de alta un activo nuevo')]),
          ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    if (picked == '__new__') {
      context.push('/inversiones/activos');
      return;
    }
    setState(() => listed.add(picked));
  }

  void _remove(String classId, String assetId, {bool archive = false}) => setState(() {
        _listed[classId]!.remove(assetId);
        _inner[assetId]!.clear();
        if (archive) _archive.add(assetId);
      });

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(assetClassesProvider).value;
    final assets = ref.watch(assetsProvider).value;
    final targets = ref.watch(targetsProvider).value;
    final portfolio = ref.watch(portfolioProvider).value;
    if (classes == null || assets == null || targets == null || portfolio == null) {
      return Scaffold(
        appBar: FaroAppBar(title: const PageTitle('Objetivos de la cartera')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final pos = {
      for (final c in portfolio.classes)
        for (final x in c.positions) x.asset.id: x,
      for (final x in portfolio.unclassified) x.asset.id: x,
    };
    final weight = {for (final c in portfolio.classes) c.assetClass.id: c.weight};
    if (!_loaded) _load(classes, assets, targets, pos);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final names = {for (final a in assets) a.id: a.name};
    final macroSum = _macro.values.fold(Decimal.zero, (s, r) => s + _num(r.target));

    Widget pctField(TextEditingController c, String label, {String suffix = '%'}) => PercentField(
          label: label,
          controller: c,
          suffix: suffix,
          textAlign: TextAlign.end,
          onChanged: (_) => setState(() {}),
        );

    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Objetivos de la cartera')),
      body: FormListView(children: [
        SectionCard(
          title: 'Peso de cada categoría',
          subtitle: 'Objetivo y rango admitido (mínimo y máximo). La tolerancia, en puntos, marca cuándo un '
              'activo se aleja de su objetivo dentro de la categoría.',
          children: [
            for (final c in classes) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
                  Row(children: [
                    Expanded(child: Text(c.name, style: tt.titleSmall)),
                    if (weight[c.id] != null) Text('ahora ${pct(weight[c.id]!, decimals: 1)}', style: tt.bodySmall),
                  ]),
                  FieldRow(minWidth: 130, children: [
                    pctField(_macro[c.id]!.target, 'Objetivo'),
                    pctField(_macro[c.id]!.min, 'Mínimo'),
                    pctField(_macro[c.id]!.max, 'Máximo'),
                    pctField(_macro[c.id]!.tol, 'Tolerancia', suffix: 'pp'),
                  ]),
                ]),
              ),
              const Divider(height: 8),
            ],
            ListTile(
              title: const Text('Suma de objetivos'),
              trailing: Text('${_fmt(macroSum)} %',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: macroSum == Decimal.fromInt(100) ? null : cs.error)),
            ),
          ],
        ),
        for (final c in classes)
          if (_listed[c.id]!.isNotEmpty || _num(_macro[c.id]!.target) > Decimal.zero)
            Builder(builder: (context) {
              final ids = _listed[c.id]!;
              final sum = ids.fold(Decimal.zero, (s, id) => s + _num(_inner[id]!));
              final ok = sum == Decimal.fromInt(100) || sum == Decimal.zero;
              return SectionCard(
                key: Key('reparto-${c.id}'),
                title: 'Reparto en ${c.name}',
                subtitle: 'Suma ${_fmt(sum)} %${ok ? '' : ' · tiene que sumar 100 %'}',
                children: [
                  for (final id in ids)
                    Padding(
                      key: Key('target-$id'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                      child: Row(children: [
                        Expanded(
                          child: FieldRow(minWidth: 120, flex: const [3, 2], children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(names[id] ?? 'Activo', style: tt.bodyLarge),
                              Text(
                                _hasMoney(pos[id])
                                    ? '${eur(pos[id]!.value)} · ${pct(pos[id]!.innerWeight, decimals: 1)} '
                                        'de ${c.name.toLowerCase()}'
                                    : 'Sin posición',
                                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ]),
                            pctField(_inner[id]!, 'Objetivo'),
                          ]),
                        ),
                        OptionsMenu<String>(
                          options: [
                            const MenuOption('remove', 'Quitar del reparto'),
                            if (!_hasMoney(pos[id]))
                              const MenuOption('archive', 'Quitar y archivar el activo', destructive: true),
                            const MenuOption('open', 'Ver el activo'),
                          ],
                          onSelected: (v) => switch (v) {
                            'remove' => _remove(c.id, id),
                            'archive' => _remove(c.id, id, archive: true),
                            _ => context.push('/inversiones/activo/$id'),
                          },
                        ),
                      ]),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir activo'),
                      onPressed: () => _add(c, assets),
                    ),
                  ),
                ],
              );
            }),
        if (_archive.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text('Al guardar se archivarán: ${_archive.map((id) => names[id]).join(', ')}'),
              subtitle: const Text('Sin posición: dejan de salir en la cartera (su historial se conserva).'),
              trailing: TextButton(
                onPressed: () => setState(() {
                  _loaded = false;
                }),
                child: const Text('Deshacer'),
              ),
            ),
          ),
        if (_error != null) ErrorText(_error),
        FilledButton(key: const Key('save-targets'), onPressed: _busy ? null : _save, child: const Text('Guardar objetivos')),
        const NoAdviceNote(text: 'Los objetivos los decides tú; Fanal no propone ninguno.'),
      ]),
    );
  }
}
