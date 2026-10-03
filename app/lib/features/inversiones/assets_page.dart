import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show showSnack, shortDate;
import '../patrimonio/data.dart' show networthHistoryProvider, performanceProvider;
import 'data.dart';
import 'exposure_page.dart';
import 'tx_sheet.dart';

/// Activos: los de la cartera y la watchlist (seguimiento sin dinero).
class AssetsPage extends ConsumerWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetsProvider);
    final classes = {for (final c in ref.watch(assetClassesProvider).value ?? const <AssetClassOut>[]) c.id: c.name};
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Activos y watchlist')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-asset'),
        icon: const Icon(Icons.add),
        label: const Text('Activo'),
        onPressed: () => showAssetSheet(context, ref),
      ),
      body: assets.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) {
          final mine = items.where((a) => !a.watchlist).toList();
          final watch = items.where((a) => a.watchlist).toList();
          Widget tile(AssetOut a) {
            final type = assetTypeLabels[AssetInTypeEnum.values.firstWhere((t) => t.value == a.type.value)] ?? a.type.value;
            final cls = a.assetClassId == null ? '' : classes[a.assetClassId] ?? '';
            return ListTile(
              title: Text(a.name),
              subtitle: Text([
                type,
                // "Cripto · Cripto", "Fondo · Fondos": la categoría solo si dice algo más que el tipo
                if (!_sameMeaning(type, cls)) cls,
                if (a.isin != null) a.isin!,
                if (a.ticker != null) a.ticker!,
                switch (a.priceProvider) {
                  AssetOutPriceProviderEnum.ft => 'precio: FT',
                  AssetOutPriceProviderEnum.coingecko => 'precio: CoinGecko',
                  AssetOutPriceProviderEnum.manual => 'precio manual',
                },
              ].where((s) => s.isNotEmpty).join(' · ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/inversiones/activo/${a.id}'),
            );
          }

          return ListView(padding: const EdgeInsets.only(bottom: 96), children: [
            SectionHeader('En cartera', trailing: Text('${mine.length}')),
            if (mine.isEmpty)
              const ListTile(
                title: Text('Sin activos en cartera'),
                subtitle: Text('Añade uno con «Activo» o importa tus operaciones.'),
              ),
            for (final a in mine) tile(a),
            SectionHeader(
              'En seguimiento (watchlist)',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${watch.length}'),
                const InfoTip('watchlist'),
              ]),
            ),
            if (watch.isEmpty)
              const ListTile(
                key: Key('watchlist-empty'),
                leading: Icon(Icons.visibility_outlined),
                title: Text('No sigues ningún activo'),
                subtitle: Text('Marca «Solo seguimiento» en un activo para ver su precio sin tenerlo.'),
              ),
            for (final a in watch) tile(a),
          ]);
        },
      ),
    );
  }
}

/// "Fondo" y "Fondos", "Cripto" y "cripto", "Acción" y "Acciones": dicen lo mismo.
bool _sameMeaning(String a, String b) {
  String norm(String s) {
    var t = s.trim().toLowerCase();
    for (final (x, y) in [('á', 'a'), ('é', 'e'), ('í', 'i'), ('ó', 'o'), ('ú', 'u')]) {
      t = t.replaceAll(x, y);
    }
    if (t.endsWith('es') && t.length > 4) return t.substring(0, t.length - 2);
    if (t.endsWith('s')) return t.substring(0, t.length - 1);
    return t;
  }

  return norm(a) == norm(b);
}

/// Alta o edición de un activo.
Future<void> showAssetSheet(BuildContext context, WidgetRef ref, {AssetOut? existing}) =>
    showFormPanel<void>(context, builder: (_) => _AssetSheet(existing: existing));

class _AssetSheet extends ConsumerStatefulWidget {
  const _AssetSheet({this.existing});
  final AssetOut? existing;

  @override
  ConsumerState<_AssetSheet> createState() => _AssetSheetState();
}

class _AssetSheetState extends ConsumerState<_AssetSheet> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _isin = TextEditingController(text: widget.existing?.isin);
  late final _ticker = TextEditingController(text: widget.existing?.ticker);
  late final _cg = TextEditingController(text: widget.existing?.coingeckoId);
  late AssetInTypeEnum _type = widget.existing == null
      ? AssetInTypeEnum.fondo
      : AssetInTypeEnum.values.firstWhere((t) => t.value == widget.existing!.type.value);
  late String? _class = widget.existing?.assetClassId;
  late String? _platform = widget.existing?.platformId;
  late bool _watch = widget.existing?.watchlist ?? false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _isin, _ticker, _cg]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Fuente de precio según el tipo: fondos por ISIN (FT), cripto por CoinGecko; el resto, manual.
  AssetInPriceProviderEnum get _provider {
    if ((_type == AssetInTypeEnum.fondo || _type == AssetInTypeEnum.etf) && _isin.text.trim().length == 12) {
      return AssetInPriceProviderEnum.ft;
    }
    if (_type == AssetInTypeEnum.cripto && _cg.text.trim().isNotEmpty) return AssetInPriceProviderEnum.coingecko;
    return AssetInPriceProviderEnum.manual;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return setState(() => _error = 'Pon un nombre');
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(apiProvider).getInversionesApi();
    final isin = _isin.text.trim().toUpperCase();
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    try {
      if (widget.existing == null) {
        await api.createAsset(assetIn: AssetIn(
          name: _name.text.trim(), type: _type, assetClassId: _class, platformId: _platform,
          isin: isin.isEmpty ? null : isin, ticker: opt(_ticker), coingeckoId: opt(_cg),
          priceProvider: _provider, priceRef: _provider == AssetInPriceProviderEnum.ft ? '$isin:EUR' : null,
          watchlist: _watch,
        ));
      } else {
        await api.patchAsset(assetId: widget.existing!.id, assetPatch: AssetPatch(
          name: _name.text.trim(), assetClassId: _class, platformId: _platform,
          isin: isin.isEmpty ? null : isin, ticker: opt(_ticker), coingeckoId: opt(_cg),
          priceProvider: AssetPatchPriceProviderEnum.values.firstWhere((p) => p.value == _provider.value),
          priceRef: _provider == AssetInPriceProviderEnum.ft ? '$isin:EUR' : null,
          watchlist: _watch,
        ));
      }
      refreshInv(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(assetClassesProvider).value ?? const <AssetClassOut>[];
    final platforms = ref.watch(platformsProvider).value ?? const <PlatformOut>[];
    final fund = _type == AssetInTypeEnum.fondo || _type == AssetInTypeEnum.etf;
    return FormPanel(
      title: widget.existing == null ? 'Nuevo activo' : 'Editar activo',
      onSubmit: _busy ? null : _save,
      actions: FormActions(
        primaryKey: const Key('save-asset'),
        primaryLabel: 'Guardar',
        busy: _busy,
        expand: context.isCompact,
        onPrimary: _save,
      ),
      children: [
        FaroTextField(key: const Key('asset-name'), label: 'Nombre', controller: _name),
        if (widget.existing == null)
          ChoiceChipsField<AssetInTypeEnum>(
            label: 'Tipo',
            options: [for (final e in assetTypeLabels.entries) Segment(e.key, e.value)],
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
        SelectField<String?>(
          label: 'Categoría',
          value: _class,
          options: [
            const SelectOption(null, 'Sin categoría'),
            for (final c in classes) SelectOption(c.id, c.name),
          ],
          onChanged: (v) => setState(() => _class = v),
        ),
        SelectField<String?>(
          label: 'Plataforma',
          value: _platform,
          options: [
            const SelectOption(null, 'Sin plataforma'),
            for (final p in platforms) SelectOption(p.id, p.name),
          ],
          onChanged: (v) => setState(() => _platform = v),
        ),
        if (fund || _type == AssetInTypeEnum.accion)
          FaroTextField(
            label: 'ISIN',
            controller: _isin,
            textCapitalization: TextCapitalization.characters,
            helper: fund ? 'Con el ISIN, Fanal busca el valor liquidativo cada día.' : null,
            onChanged: (_) => setState(() {}),
          ),
        if (_type == AssetInTypeEnum.cripto || _type == AssetInTypeEnum.accion)
          FaroTextField(label: 'Ticker', controller: _ticker, hint: 'BTC, ETH…'),
        if (_type == AssetInTypeEnum.cripto)
          FaroTextField(
            label: 'Id de CoinGecko',
            controller: _cg,
            hint: 'bitcoin, ethereum…',
            helper: 'Con él, Fanal actualiza el precio solo.',
            onChanged: (_) => setState(() {}),
          ),
        SwitchField(
          title: 'Solo seguimiento (watchlist)',
          value: _watch,
          onChanged: (v) => setState(() => _watch = v),
        ),
        Text(switch (_provider) {
          AssetInPriceProviderEnum.ft => 'Precio automático: FT (respaldo: Yahoo).',
          AssetInPriceProviderEnum.coingecko => 'Precio automático: CoinGecko (respaldo: Kraken).',
          AssetInPriceProviderEnum.manual => 'Precio manual: lo actualizas tú desde el detalle del activo.',
        }),
        if (_error != null) ErrorText(_error),
      ],
    );
  }
}

/// Detalle: posición, lotes FIFO (fiscalidad), ventas realizadas y operaciones.
class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({super.key, required this.id});
  final String id;

  Future<void> _archive(BuildContext context, WidgetRef ref, AssetOut a) async {
    final ok = await confirmDialog(
      context,
      title: '¿Archivar ${a.name}?',
      message: 'Deja de salir en la cartera y en los objetivos. Si no tiene operaciones se borra; si las tiene, '
          'su historial se conserva.',
      confirmLabel: 'Archivar',
    );
    if (!ok) return;
    try {
      await ref.read(apiProvider).getInversionesApi().deleteAsset(assetId: a.id);
      refreshInv(ref);
      if (context.mounted) context.go('/inversiones/activos');
    } catch (e) {
      if (context.mounted) showSnack(context, apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(assetDetailProvider(id));
    final a = d.value?.position.asset;
    return Scaffold(
      appBar: FaroAppBar(title: PageTitle(a?.name ?? 'Activo')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Operación'),
        onPressed: () => showTxSheet(context, ref, assetId: id),
      ),
      body: d.when(
        loading: () => const SkeletonPage(kpis: 3),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (x) {
          final p = x.position;
          final big = FaroText.kpi(context);
          return ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 96), children: [
            // Acciones con nombre (antes, en un menú "⋮"), con 48 px de alto también en escritorio
            Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
              OutlinedButton.icon(
                key: const Key('asset-edit'),
                style: _bigButton,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                onPressed: () => showAssetSheet(context, ref, existing: p.asset),
              ),
              OutlinedButton.icon(
                style: _bigButton,
                icon: const Icon(Icons.price_change_outlined, size: 18),
                label: const Text('Poner precio a mano'),
                onPressed: () => _manualPrice(context, ref, p.asset),
              ),
              OutlinedButton.icon(
                style: _bigButton,
                icon: const Icon(Icons.public, size: 18),
                label: const Text('Composición'),
                onPressed: () => showCompositionDialog(context, ref, p.asset),
              ),
              OutlinedButton.icon(
                style: _bigButton,
                icon: const Icon(Icons.build_outlined, size: 18),
                label: const Text('Corregir posición'),
                onPressed: () => _correction(context, ref, p),
              ),
              TextButton.icon(
                key: const Key('asset-archive'),
                style: _bigButton,
                icon: Icon(Icons.archive_outlined, size: 18, color: Theme.of(context).colorScheme.error),
                label: Text('Archivar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onPressed: () => _archive(context, ref, p.asset),
              ),
            ]),
            const SizedBox(height: Space.md),
            KpiGrid(minWidth: 165, children: [
              KpiCard(label: 'Valor', value: MoneyText.api(p.value, compact: true, style: big), emphasis: true),
              KpiCard(
                label: 'Ganancia',
                value: MoneyText.api(p.pnl, plus: true, colored: true, style: big),
                delta: DeltaText(p.pnlPct == null ? null : dec(p.pnlPct)),
              ),
              KpiCard(label: 'Participaciones', valueText: qty(p.units)),
              KpiCard(label: 'PMP', info: 'pmp', valueText: unitPrice(p.avgCost), note: 'Coste ${eur(p.cost)}'),
              KpiCard(
                label: 'Precio',
                valueText: p.price == null ? 'Sin precio' : unitPrice(p.price),
                note: p.price == null ? null : 'del ${shortDate(p.priceDate)} (${p.priceSource})',
              ),
            ]),
            if (p.stale)
              Card(
                color: context.faro.warningContainer,
                child: ListTile(
                  leading: Icon(Icons.update, color: context.faro.warning),
                  title: const Text('El precio no se ha actualizado en varios días'),
                ),
              ),
            // En pantallas anchas, operaciones a la izquierda y lotes/ventas a la derecha
            LayoutBuilder(builder: (context, box) {
              final side = <Widget>[
                if (x.lots.isNotEmpty)
                  Card(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const SectionHeader('Lotes (FIFO, para Hacienda)'),
                      // Los 5 más recientes (van del más antiguo al más nuevo); el resto, con "Ver todos"
                      _ShowSome(fromEnd: true, more: 'Ver todos', children: [
                        for (final l in x.lots)
                          ListRow(
                            lead: '${shortDate(l.acquired)} ${l.acquired.year % 100}',
                            title: '${qty(l.units)}${nbsp}part.',
                            trailing: Text(eur(l.cost)),
                          ),
                      ]),
                    ]),
                  ),
                if (x.realized.isNotEmpty)
                  Card(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const SectionHeader('Ventas · ganancia según FIFO (fiscal) y según PMP'),
                      for (final r in x.realized)
                        ListRow(
                          lead: '${shortDate(r.date)} ${r.date.year % 100}',
                          title: '${qty(r.units)}${nbsp}part. · recibido ${eur(r.proceeds)}',
                          subtitle: 'FIFO ${eur(r.gainFifo, plus: true)} · PMP ${eur(r.gainPmp, plus: true)}',
                        ),
                    ]),
                  ),
                if (dec(x.income).sign > 0)
                  Card(
                    child: ListTile(title: const Text('Dividendos e intereses cobrados'), trailing: Text(eur(x.income))),
                  ),
              ];
              final anyPending = x.transactions.any((t) => t.status == TxOutStatusEnum.pendienteVl);
              final ops = Card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SectionHeader('Operaciones (${x.transactions.length})'),
                  // Las 5 últimas (vienen de la más nueva a la más antigua); el resto, con "Ver todas"
                  _ShowSome(children: [
                    for (final t in x.transactions)
                      ListRow(
                        key: Key('tx-row-${t.id}'),
                        // El hueco de "Confirmar" solo si alguna operación lo necesita
                        reserveAction: anyPending,
                        lead: '${shortDate(t.tradeDate)} ${t.tradeDate.year % 100}',
                        title: txKindLabel(t.kind),
                        subtitle: [
                          if (t.units != null) '${qty(t.units)}${nbsp}part.',
                          if (t.price != null) 'a ${unitPrice(t.price)}',
                          if (t.avgCost != null) 'PMP ${unitPrice(t.avgCost)}',
                          if (t.status == TxOutStatusEnum.pendienteVl) 'pendiente de VL',
                        ].join(' · '),
                        // Borrar, en el menú de cada fila (con confirmación): nada de una papelera roja
                        // por operación
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (dec(t.amountEur).sign != 0) MoneyText.api(t.amountEur),
                          OptionsMenu<_TxOption>(
                            key: Key('tx-delete-${t.id}'),
                            tooltip: 'Opciones de la operación',
                            options: const [
                              MenuOption(_TxOption.delete, 'Borrar operación', icon: Icons.delete_outline,
                                  destructive: true),
                            ],
                            onSelected: (_) => _deleteTx(context, ref, t),
                          ),
                        ]),
                        actions: [
                          if (t.status == TxOutStatusEnum.pendienteVl)
                            RowAction(
                              icon: Icons.check_circle_outline,
                              label: 'Confirmar',
                              primary: true,
                              onPressed: () => showSettleDialog(context, ref, t),
                            ),
                        ],
                      ),
                  ]),
                ]),
              );
              return box.maxWidth >= 900
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
                      Expanded(flex: 3, child: ops),
                      if (side.isNotEmpty)
                        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side)),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...side, ops]);
            }),
            const NoAdviceNote(),
          ]);
        },
      ),
    );
  }
}

enum _TxOption { delete }

/// Las [visible] primeras filas (o las últimas, con [fromEnd]) y un "Ver todas (N)" que despliega el
/// resto en el sitio.
class _ShowSome extends StatefulWidget {
  const _ShowSome({required this.children, this.fromEnd = false, this.more = 'Ver todas'});
  final List<Widget> children;
  final bool fromEnd;
  final String more;
  static const visible = 5;

  @override
  State<_ShowSome> createState() => _ShowSomeState();
}

class _ShowSomeState extends State<_ShowSome> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final rows = widget.children;
    const n = _ShowSome.visible;
    if (_all || rows.length <= n) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    }
    final shown = widget.fromEnd ? rows.sublist(rows.length - n) : rows.sublist(0, n);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...shown,
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
          child: TextButton(
            onPressed: () => setState(() => _all = true),
            child: Text('${widget.more} (${rows.length})'),
          ),
        ),
      ),
    ]);
  }
}

/// Botones de acción de la ficha: 48 px de alto (objetivo táctil) aunque el escritorio use densidad
/// compacta.
const _bigButton = ButtonStyle(
  visualDensity: VisualDensity.standard,
  minimumSize: WidgetStatePropertyAll(Size(64, 48)),
);

Future<void> _deleteTx(BuildContext context, WidgetRef ref, TxOut t) async {
  final ok = await confirmDialog(
    context,
    title: '¿Borrar la operación?',
    message: '${txKindLabel(t.kind)} del ${shortDate(t.tradeDate)} ${t.tradeDate.year}. La posición se recalcula.',
  );
  if (!ok) return;
  try {
    await ref.read(apiProvider).getInversionesApi().deleteTransaction(txId: t.id);
    refreshInv(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

/// Formulario corto (los campos y sus controladores los pone quien lo abre): `true` si se confirma.
Future<bool> _shortForm(BuildContext context,
    {required String title, required String primaryLabel, required List<Widget> children}) async {
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => FormPanel(
      title: title,
      onSubmit: () => Navigator.pop(c, true),
      actions: FormActions(primaryLabel: primaryLabel, expand: c.isCompact, onPrimary: () => Navigator.pop(c, true)),
      children: children,
    ),
  );
  return ok == true;
}

Future<void> _manualPrice(BuildContext context, WidgetRef ref, AssetOut a) async {
  final ctrl = TextEditingController();
  final ok = await _shortForm(
    context,
    title: 'Precio de ${a.name} hoy',
    primaryLabel: 'Guardar',
    children: [MoneyField(label: 'Precio', controller: ctrl, autofocus: true)],
  );
  final v = parseEsDecimal(ctrl.text);
  if (!ok || v == null) return;
  final now = DateTime.now();
  try {
    await ref.read(apiProvider).getInversionesApi().putPrice(
        assetId: a.id, priceIn: PriceIn(date: DateTime.utc(now.year, now.month, now.day), price: v.toString()));
    refreshInv(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

Future<void> _correction(BuildContext context, WidgetRef ref, PositionOut p) async {
  final units = TextEditingController(text: qty(p.units));
  final avg = TextEditingController(text: qty(p.avgCost));
  final reason = TextEditingController();
  final ok = await _shortForm(
    context,
    title: 'Corregir posición',
    primaryLabel: 'Corregir',
    children: [
      const Text('Para cuadrar con tu broker. Queda registrado con su motivo.'),
      FieldRow(children: [
        UnitsField(label: 'Participaciones', controller: units),
        MoneyField(label: 'Precio medio (PMP)', controller: avg),
      ]),
      FaroTextField(label: 'Motivo', controller: reason),
    ],
  );
  if (!ok) return;
  try {
    await ref.read(apiProvider).getInversionesApi().correct(
          assetId: p.asset.id,
          correctionIn: CorrectionIn(
            units: parseEsDecimal(units.text).toString(),
            avgCost: parseEsDecimal(avg.text).toString(),
            reason: reason.text.trim(),
          ),
        );
    refreshInv(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

/// Plataformas (broker, exchange…) y con cuántos decimales dan las participaciones.
class PlatformsPage extends ConsumerWidget {
  const PlatformsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ps = ref.watch(platformsProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Plataformas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-platform'),
        icon: const Icon(Icons.add),
        label: const Text('Plataforma'),
        onPressed: () => _platformDialog(context, ref, null),
      ),
      body: ps.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.account_balance_outlined,
                title: 'Sin plataformas',
                text: 'Tu bróker, exchange o banco: dónde tienes cada activo.',
                actionLabel: 'Añadir plataforma',
                onAction: () => _platformDialog(context, ref, null),
              )
            : ListView(padding: const EdgeInsets.only(bottom: 96), children: [
                for (final p in items)
                  ListTile(
                    title: Text(p.name),
                    subtitle: Text('${platformKindLabel(p.kind.value)} · participaciones con ${p.unitsDecimals} decimales'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _platformDialog(context, ref, p),
                  ),
              ]),
      ),
    );
  }
}

Future<void> _platformDialog(BuildContext context, WidgetRef ref, PlatformOut? p) async {
  final name = TextEditingController(text: p?.name);
  final decimals = TextEditingController(text: '${p?.unitsDecimals ?? 4}');
  var kind = p == null ? PlatformInKindEnum.broker : PlatformInKindEnum.values.firstWhere((k) => k.value == p.kind.value);
  final ok = await _shortForm(
    context,
    title: p == null ? 'Nueva plataforma' : 'Editar plataforma',
    primaryLabel: 'Guardar',
    children: [
      FaroTextField(label: 'Nombre', controller: name),
      StatefulBuilder(
        builder: (c, setState) => ChoiceChipsField<PlatformInKindEnum>(
          label: 'Tipo',
          options: [for (final e in platformKindLabels.entries) Segment(e.key, e.value)],
          value: kind,
          onChanged: (v) => setState(() => kind = v),
        ),
      ),
      UnitsField(label: 'Decimales de las participaciones', controller: decimals, integer: true),
    ],
  );
  if (!ok || name.text.trim().isEmpty) return;
  final body = PlatformIn(
    name: name.text.trim(),
    kind: kind,
    unitsDecimals: int.tryParse(decimals.text) ?? 4,
  );
  final api = ref.read(apiProvider).getInversionesApi();
  try {
    if (p == null) {
      await api.createPlatform(platformIn: body);
    } else {
      await api.updatePlatform(platformId: p.id, platformIn: body);
    }
    refreshInv(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

/// Ajustes del módulo.
class InvSettingsPage extends ConsumerStatefulWidget {
  const InvSettingsPage({super.key});

  @override
  ConsumerState<InvSettingsPage> createState() => _InvSettingsPageState();
}

class _InvSettingsPageState extends ConsumerState<InvSettingsPage> {
  TextEditingController? _monthly;
  TextEditingController? _minOp;
  DateTime? _start;
  bool _startLoaded = false;
  String? _error;

  bool _busy = false;

  String _f(String? v) => v == null ? '' : dec(v).toStringAsFixed(2).replaceAll('.', ',');

  Future<void> _save() async {
    final m = parseEsDecimal(_monthly!.text);
    final o = parseEsDecimal(_minOp!.text);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).getInversionesApi().putSettings(invSettingsIn: InvSettingsIn(
        monthlyContribution: m == null ? null : apiAmount(m),
        minOperation: apiAmount(o ?? dec('0')),
        trackStart: _start == null ? null : DateTime.utc(_start!.year, _start!.month, _start!.day),
        clearTrackStart: _start == null,
      ));
      ref.invalidate(performanceProvider);
      ref.invalidate(networthHistoryProvider);
      refreshInv(ref);
      if (mounted) showSnack(context, 'Guardado');
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(invSettingsProvider).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _monthly ??= TextEditingController(text: _f(s.monthlyContribution));
    _minOp ??= TextEditingController(text: _f(s.minOperation));
    if (!_startLoaded) {
      _start = s.trackStart;
      _startLoaded = true;
    }
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Ajustes de inversiones')),
      body: FormListView(children: [
        MoneyField(label: 'Aportación mensual habitual', controller: _monthly),
        MoneyField(label: 'Importe mínimo por orden', controller: _minOp),
        DateField(
          key: const Key('track-start'),
          label: 'Inicio del seguimiento',
          value: _start,
          first: DateTime(2000),
          last: DateTime.now(),
          helper: 'La rentabilidad y las gráficas empiezan aquí y lo anterior se resume en un bloque. '
              'Tus operaciones, el PMP y el informe fiscal no cambian.',
          emptyText: 'Desde la primera operación',
          clearable: true,
          clearTooltip: 'Desde la primera operación',
          onChanged: (d) => setState(() => _start = d),
        ),
        if (_error != null) ErrorText(_error),
        // Como en Ajustes de gastos: botón compacto a la derecha
        FormActions(
          primaryKey: const Key('save-inv-settings'),
          primaryLabel: 'Guardar',
          busy: _busy,
          onPrimary: _save,
        ),
        const Text('El objetivo del fondo de emergencia y la cuenta refugio están en Gastos → Gestionar → Ajustes de gastos.'),
      ]),
    );
  }
}
