import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/share_intake.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' as gastos show importBatchesProvider, refreshAll, shortDate, showSnack, categoriesProvider, CategoryIndex;
import '../inversiones/data.dart' as inv show refreshInv, qty, txKindLabel;
import 'column_mapper.dart';

/// De dónde viene el fichero. Banco y Trade Republic van por el importador de extractos; el resto,
/// por el de operaciones de inversión.
enum ImportSource {
  myinvestor('myinvestor', 'MyInvestor', 'Órdenes de fondos · CSV', Icons.show_chart, ['csv']),
  neverless('neverless', 'Neverless', 'Cripto · CSV', Icons.currency_bitcoin, ['csv']),
  tradeRepublic('trade-republic', 'Trade Republic', 'Extracto de cuenta · PDF', Icons.picture_as_pdf_outlined, ['pdf']),
  bank('banco', 'Banco', 'Movimientos de tu cuenta · Excel, CSV o TXT', Icons.account_balance_outlined, ['csv', 'xlsx', 'txt']),
  other('otro', 'Otra plataforma', 'Cualquier CSV o Excel: eliges las columnas', Icons.table_view_outlined, ['csv', 'xlsx']);

  const ImportSource(this.slug, this.label, this.subtitle, this.icon, this.extensions);
  final String slug;
  final String label;
  final String subtitle;
  final IconData icon;
  final List<String> extensions;

  bool get isBank => this == bank || this == tradeRepublic;
  String get tutorial => switch (this) { other => 'otro', _ => slug };

  static ImportSource? fromSlug(String? s) => ImportSource.values.where((x) => x.slug == s).firstOrNull;
}

const _steps = ['Plataforma', 'Cómo descargarlo', 'Subir', 'Revisar', 'Listo'];

/// Resultados de la vista previa agrupados igual para banco y plataformas.
enum _Group { fresh, pending, known }

const _groupLabels = {_Group.fresh: 'Nuevas', _Group.pending: 'Completan pendientes', _Group.known: 'Ya estaban'};

_Group _groupOf(String outcome) => switch (outcome) {
      'new' => _Group.fresh,
      'match_planned' || 'complete_pending' => _Group.pending,
      _ => _Group.known, // duplicate, match_posted, before_opening
    };

const _bankOutcomes = {
  'new': 'Nuevo',
  'match_planned': 'Previsto → cargado',
  'match_posted': 'Ya lo habías apuntado',
  'duplicate': 'Ya importado',
  'before_opening': 'Anterior al saldo inicial',
};

/// Asistente común de importación (fase 6): plataforma → cómo descargarlo → subir (arrastrar y
/// soltar) → revisar → listo, con el historial y "Deshacer". `/gastos/importar` e
/// `/inversiones/importar` lo abren; `?fuente=…&paso=…` lleva directamente a una plataforma.
class ImportWizardPage extends ConsumerStatefulWidget {
  const ImportWizardPage({super.key, this.source, this.step, this.bankFirst = false});
  final String? source;
  final int? step; // 1..5, como en la ruta
  final bool bankFirst; // desde Gastos: Banco y Trade Republic primero

  @override
  ConsumerState<ImportWizardPage> createState() => _ImportWizardPageState();
}

class _ImportWizardPageState extends ConsumerState<ImportWizardPage> {
  late ImportSource? _source = ImportSource.fromSlug(widget.source);
  late int _step = _source == null ? 0 : ((widget.step ?? 2) - 1).clamp(0, 2);
  SharedFile? _shared;
  String? _name;
  Uint8List? _bytes;
  bool _busy = false;
  String? _error;
  bool _unrecognized = false; // el servidor no reconoce el formato: elegir columnas
  BankPreviewOut? _bank;
  PlatformPreviewOut? _platform;
  String? _profileId;
  Map<String, dynamic>? _mapping;
  bool _replace = true;
  _Group? _filter;
  final _saveAs = TextEditingController();
  ({String id, Map<String, int> counts})? _done;

  @override
  void initState() {
    super.initState();
    _shared = ref.read(sharedFileProvider);
    if (_shared != null) {
      // Un PDF compartido solo puede ser el extracto de Trade Republic
      if (_source == null && _shared!.name.toLowerCase().endsWith('.pdf')) _source = ImportSource.tradeRepublic;
      if (_source != null) WidgetsBinding.instance.addPostFrameCallback((_) => _useShared());
    }
  }

  @override
  void dispose() {
    _saveAs.dispose();
    super.dispose();
  }

  bool get _tabular => !(_name?.toLowerCase().endsWith('.pdf') ?? false);

  Future<void> _useShared() async {
    final s = _shared;
    if (s == null) return;
    final bytes = await XFile(s.path).readAsBytes();
    ref.read(sharedFileProvider.notifier).clear();
    _shared = null;
    if (!mounted) return;
    setState(() => _step = 2);
    await _onFile(s.name, bytes);
  }

  void _choose(ImportSource s) {
    setState(() {
      _source = s;
      _reset(keepSource: true);
      _step = _shared != null ? 2 : 1;
    });
    if (_shared != null) _useShared();
  }

  void _reset({bool keepSource = false}) {
    if (!keepSource) _source = null;
    _name = null;
    _bytes = null;
    _bank = null;
    _platform = null;
    _mapping = null;
    _profileId = null;
    _error = null;
    _unrecognized = false;
    _filter = null;
    _saveAs.clear();
    _done = null;
  }

  FormData _form({bool commit = false}) => FormData.fromMap({
        'file': MultipartFile.fromBytes(_bytes!, filename: _name!),
        if (!_source!.isBank) 'replace_initial': _replace ? 'true' : 'false',
        if (_mapping != null) 'mapping': jsonEncode(_mapping),
        if (_mapping == null && _profileId != null) 'profile_id': _profileId,
        if (commit && _mapping != null && _saveAs.text.trim().isNotEmpty) 'save_profile_as': _saveAs.text.trim(),
      });

  Future<void> _onFile(String name, Uint8List bytes) async {
    setState(() {
      _name = name;
      _bytes = bytes;
      _mapping = null;
      _bank = null;
      _platform = null;
    });
    await _preview();
    // Otra plataforma sin formato guardado: directamente a elegir las columnas
    if (_unrecognized && _source == ImportSource.other && mounted) await _openMapper();
  }

  Future<void> _preview() async {
    setState(() {
      _busy = true;
      _error = null;
      _unrecognized = false;
    });
    try {
      final dio = ref.read(dioProvider);
      if (_source!.isBank) {
        final r = await dio.post<Map<String, dynamic>>('/api/imports/bank/preview', data: _form());
        _bank = BankPreviewOut.fromJson(r.data!);
      } else {
        final r = await dio.post<Map<String, dynamic>>('/api/inv/imports/preview', data: _form());
        _platform = PlatformPreviewOut.fromJson(r.data!);
      }
      setState(() => _step = 3);
    } catch (e) {
      setState(() {
        _error = apiErrorMessage(e);
        _unrecognized = _tabular && e is DioException && e.response?.statusCode == 422;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMapper() async {
    if (_bytes == null) return;
    try {
      final bank = _source!.isBank;
      final ins = await inspectFile(ref, _bytes!, _name!, kind: bank ? 'bank' : 'broker');
      if (!mounted) return;
      final profiles = ref.read(bank ? bankProfilesProvider : brokerProfilesProvider).value ?? const <BankProfileOut>[];
      final profile = profiles.where((p) => p.id == _profileId).firstOrNull;
      final m = await Navigator.of(context).push<Map<String, dynamic>>(MaterialPageRoute(
        builder: (_) => ColumnMapperPage(
          title: bank ? 'Columnas del extracto' : 'Columnas de las operaciones',
          rows: ins.rows,
          roles: bank ? bankRoles : brokerRoles,
          initial: _mapping ?? profile?.mapping ?? _bank?.mapping ?? ins.suggested,
          message: _unrecognized ? (bank ? (ins.message ?? '') : 'Fanal reconoce solos MyInvestor y Neverless.') : null,
          broker: !bank,
        ),
      ));
      if (m == null) return;
      setState(() => _mapping = m);
      await _preview();
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    }
  }

  void _refresh() {
    gastos.refreshAll(ref);
    inv.refreshInv(ref);
    ref.invalidate(gastos.importBatchesProvider);
    ref.invalidate(bankProfilesProvider);
    ref.invalidate(brokerProfilesProvider);
  }

  Future<void> _commit() async {
    setState(() => _busy = true);
    try {
      final dio = ref.read(dioProvider);
      final url = _source!.isBank ? '/api/imports/bank/commit' : '/api/inv/imports/commit';
      final r = await dio.post<Map<String, dynamic>>(url, data: _form(commit: true));
      final data = r.data!;
      _refresh();
      setState(() {
        _done = (id: data['id'] as String, counts: Map<String, int>.from(data['counts'] as Map));
        _step = 4;
      });
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undoLast() async {
    final d = _done;
    if (d == null) return;
    if (await undoImport(context, ref, d.id, _name ?? 'la importación')) {
      if (mounted) setState(() => _done = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_step) {
      0 => _choosePlatform(),
      1 => _howTo(),
      2 => _upload(),
      3 => _review(),
      _ => _finished(),
    };
    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Importar')),
      body: ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xl), children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: FaroLayout.readable + 140),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StepHeader(
          steps: _steps,
          current: _step,
          onTap: _step == 4 ? null : (i) => setState(() => _step = i == 0 ? 0 : i),
        ),
        const SizedBox(height: Space.lg),
        body,
            ]),
          ),
        ),
      ]),
    );
  }

  // --- 1 · Plataforma ---------------------------------------------------------------------------
  Widget _choosePlatform() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
        if (_shared != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text('Has compartido «${_shared!.name}»'),
              subtitle: const Text('Elige de dónde es y Fanal te enseña lo que va a importar.'),
              trailing: TextButton(
                key: const Key('discard-shared'),
                onPressed: () {
                  ref.read(sharedFileProvider.notifier).clear();
                  setState(() => _shared = null);
                },
                child: const Text('Descartar'),
              ),
            ),
          )
        else
          Text('¿De dónde es el fichero?', style: Theme.of(context).textTheme.titleMedium),
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 900 ? 3 : (box.maxWidth >= 520 ? 2 : 1);
          final w = (box.maxWidth - Space.sm * (cols - 1)) / cols;
          return Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
            for (final s in widget.bankFirst
                ? [ImportSource.bank, ImportSource.tradeRepublic, ...ImportSource.values.where((x) => !x.isBank)]
                : ImportSource.values)
              SizedBox(
                width: w,
                child: Card(
                  key: Key('source-${s.slug}'),
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.md),
                    onTap: () => _choose(s),
                    child: Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Row(spacing: Space.md, children: [
                        Icon(s.icon, size: 28),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.label, style: Theme.of(context).textTheme.titleMedium),
                            Text(s.subtitle, style: FaroText.caption(context)),
                          ]),
                        ),
                        const Icon(Icons.chevron_right),
                      ]),
                    ),
                  ),
                ),
              ),
          ]);
        }),
        const ImportHistory(),
      ]);

  // --- 2 · Cómo descargarlo -----------------------------------------------------------------------
  Widget _howTo() {
    final s = _source!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: TutorialText(s.tutorial),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
            Text('Formatos: ${s.extensions.map((e) => e.toUpperCase()).join(', ')}'),
            const Text('Duplicados: lo que ya tengas no se vuelve a importar, aunque subas el mismo fichero dos veces.'),
            const Text('Deshacer: antes de importar ves todo lo que va a entrar, y cada importación se puede deshacer '
                'después desde «Importaciones anteriores».'),
          ]),
        ),
      ),
      _nav(back: () => setState(() => _step = 0), next: () => setState(() => _step = 2), nextLabel: 'Ya tengo el fichero',
          nextKey: const Key('howto-next')),
    ]);
  }

  // --- 3 · Subir ------------------------------------------------------------------------------------
  Widget _upload() {
    final s = _source!;
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      if (s == ImportSource.bank || s == ImportSource.other)
        ProfilePicker(
          provider: s.isBank ? bankProfilesProvider : brokerProfilesProvider,
          value: _profileId,
          autoLabel: s.isBank ? 'Automático' : 'Elegir las columnas',
          onChanged: (v) {
            setState(() {
              _profileId = v;
              _mapping = null;
            });
            if (_bytes != null) _preview();
          },
        ),
      FileDropZone(
        extensions: s.extensions,
        busy: _busy,
        fileName: _name,
        error: _error == null ? null : (_unrecognized ? 'Formato no reconocido. $_error' : _error),
        hint: android ? 'También puedes compartir el fichero con Fanal desde la app de tu banco o plataforma.' : null,
        onFile: _onFile,
      ),
      if (_unrecognized)
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            key: const Key('open-mapper'),
            icon: const Icon(Icons.view_column_outlined),
            label: const Text('Elegir las columnas'),
            onPressed: _busy ? null : _openMapper,
          ),
        ),
      _nav(back: () => setState(() => _step = 1)),
    ]);
  }

  // --- 4 · Revisar ----------------------------------------------------------------------------------
  Widget _review() {
    final bank = _bank;
    final plat = _platform;
    final counts = bank?.counts ?? plat?.counts ?? const <String, int>{};
    final byGroup = <_Group, int>{};
    for (final e in counts.entries) {
      byGroup[_groupOf(e.key)] = (byGroup[_groupOf(e.key)] ?? 0) + e.value;
    }
    final problems = bank?.errors ?? plat?.warnings ?? const <String>[];
    final toImport = (byGroup[_Group.fresh] ?? 0) + (byGroup[_Group.pending] ?? 0);
    final big = FaroText.kpi(context);
    final idx = gastos.CategoryIndex(ref.watch(gastos.categoriesProvider).value ?? const []);
    final rows = <Widget>[
      if (bank != null)
        for (final ln in bank.lines)
          if (_filter == null || _groupOf(ln.outcome) == _filter)
            ListRow(
              lead: _day(ln.date),
              title: ln.concept,
              subtitle: [_bankOutcomes[ln.outcome] ?? ln.outcome, if (ln.categoryId != null) idx.label(ln.categoryId)]
                  .join(' · '),
              trailing: MoneyText.api(ln.amount, plus: true),
            ),
      if (plat != null)
        for (final o in plat.ops)
          if (_filter == null || _groupOf(o.outcome.value) == _filter)
            ListRow(
              lead: _day(o.date),
              title: '${inv.txKindLabel(TxOutKindEnum.values.firstWhere((k) => k.value == o.kind.value))} · ${o.assetName}',
              subtitle: [
                '${inv.qty(o.units)}${nbsp}part.',
                switch (o.outcome) {
                  PlatformOpOutOutcomeEnum.duplicate => 'ya estaba',
                  PlatformOpOutOutcomeEnum.completePending => 'completa una pendiente',
                  _ => 'nueva',
                },
                if (o.note != null) o.note!,
              ].join(' · '),
              trailing: MoneyText.api(o.amount),
            ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      Text('${plat?.platform ?? _source!.label} · ${_name ?? ''}', style: Theme.of(context).textTheme.titleMedium),
      KpiGrid(minWidth: 150, children: [
        KpiCard(key: const Key('count-new'), label: bank != null ? 'Nuevos' : 'Nuevas',
            value: Text('${byGroup[_Group.fresh] ?? 0}', style: big), emphasis: true),
        KpiCard(label: 'Completan pendientes', value: Text('${byGroup[_Group.pending] ?? 0}', style: big),
            note: _source!.isBank ? 'Previstos que pasan a cargados' : 'Órdenes pendientes de VL'),
        KpiCard(label: 'Ya estaban', value: Text('${byGroup[_Group.known] ?? 0}', style: big), note: 'No se duplican'),
        KpiCard(label: bank != null ? 'Filas con errores' : 'Avisos', value: Text('${problems.length}', style: big)),
      ]),
      if (bank?.fileBalance != null)
        Card(
          child: ListTile(
            leading: Icon(
              dec(bank!.fileBalance) == dec(bank.balanceAfter) ? Icons.check_circle : Icons.warning_amber,
              color: dec(bank.fileBalance) == dec(bank.balanceAfter) ? context.faro.gain : context.faro.warning,
            ),
            title: const Text('¿Cuadra el saldo?'),
            subtitle: Text('Extracto ${eur(bank.fileBalance)} · tu cuenta tras importar ${eur(bank.balanceAfter)}'
                '${dec(bank.fileBalance) == dec(bank.balanceAfter) ? '' : ' · diferencia ${formatEur(dec(bank.fileBalance) - dec(bank.balanceAfter), showPlus: true)}'}'),
          ),
        ),
      if (problems.isNotEmpty)
        Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHeader(bank != null ? 'Filas que no se entienden' : 'Avisos'),
            for (final p in problems) ListRow(leading: const Icon(Icons.info_outline, size: 20), title: p),
          ]),
        ),
      if (plat != null) ...[
        SwitchField(
          title: 'Sustituir las posiciones iniciales',
          subtitle: 'Si estos activos se dieron de alta con su posición (p. ej. desde el Excel), se cambia por el '
              'historial real: fechas de compra reales para Hacienda y rentabilidad desde el inicio.',
          value: _replace,
          onChanged: _busy
              ? null
              : (v) {
                  setState(() => _replace = v);
                  _preview();
                },
        ),
        if (plat.createAssets.isNotEmpty)
          Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SectionHeader('Activos nuevos (${plat.createAssets.length})'),
              for (final a in plat.createAssets)
                ListRow(leading: const Icon(Icons.fiber_new_outlined, size: 20), title: a.name, subtitle: a.key),
            ]),
          ),
        if (plat.positions.isNotEmpty)
          Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SectionHeader('Cómo quedan tus posiciones'),
              for (final x in plat.positions)
                ListRow(
                  title: x.name,
                  subtitle: '${inv.qty(x.unitsNow)} → ${inv.qty(x.unitsAfter)}${nbsp}part.'
                      '${x.replacedInitial ? ' · sustituye la posición inicial' : ''}',
                  trailing: dec(x.unitsAfter).sign > 0 ? Text('PMP ${formatEur(dec(x.avgCostAfter), decimals: 4)}') : null,
                ),
            ]),
          ),
      ],
      ChoiceChipsField<_Group?>(
        label: 'Ver',
        options: [
          const Segment(null, 'Todas'),
          for (final g in _Group.values)
            if ((byGroup[g] ?? 0) > 0)
              Segment(g, '${bank != null && g == _Group.fresh ? 'Nuevos' : _groupLabels[g]} (${byGroup[g]})'),
        ],
        value: _filter,
        onChanged: (v) => setState(() => _filter = v),
      ),
      Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ...rows.take(300),
          if (rows.length > 300)
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Text('Y ${rows.length - 300} más.', style: FaroText.caption(context)),
            ),
          if (rows.isEmpty)
            const Padding(padding: EdgeInsets.all(Space.lg), child: Text('Nada en este grupo.')),
        ]),
      ),
      if (_mapping != null)
        FaroTextField(
          key: const Key('save-format-as'),
          label: 'Guardar este formato como (opcional)',
          controller: _saveAs,
          helper: 'P. ej. el nombre del banco o de la plataforma: la próxima vez lo eliges al subir',
        ),
      if (_error != null) ErrorText(_error),
      Wrap(spacing: Space.sm, runSpacing: Space.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Cambiar de fichero'),
          onPressed: _busy ? null : () => setState(() => _step = 2),
        ),
        if (_tabular)
          OutlinedButton.icon(
            key: const Key('adjust-columns'),
            icon: const Icon(Icons.view_column_outlined),
            label: const Text('Ajustar columnas'),
            onPressed: _busy ? null : _openMapper,
          ),
        FilledButton.icon(
          key: const Key('commit-import'),
          icon: _busy
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_done),
          label: Text(toImport == 0 ? 'Nada nuevo que importar' : 'Importar $toImport'),
          onPressed: _busy || toImport == 0 ? null : _commit,
        ),
      ]),
    ]);
  }

  // --- 5 · Listo --------------------------------------------------------------------------------------
  Widget _finished() {
    final d = _done;
    final c = d?.counts ?? const <String, int>{};
    final fresh = c['new'] ?? 0;
    final pending = (c['match_planned'] ?? 0) + (c['complete_pending'] ?? 0);
    final bank = _source?.isBank ?? true;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(spacing: Space.sm, children: [
            Icon(d == null ? Icons.undo : Icons.check_circle, size: 48, color: d == null ? null : context.faro.gain),
            Text(d == null ? 'Importación deshecha' : 'Importado', style: Theme.of(context).textTheme.titleLarge),
            if (d != null)
              Text('$fresh ${bank ? 'movimientos nuevos' : 'operaciones nuevas'}'
                  '${pending > 0 ? ' · $pending ${bank ? 'previstos cargados' : 'pendientes completadas'}' : ''}',
                  textAlign: TextAlign.center),
            Wrap(alignment: WrapAlignment.center, spacing: Space.sm, runSpacing: Space.sm, children: [
              if (d != null)
                OutlinedButton.icon(
                  key: const Key('undo-last'),
                  icon: const Icon(Icons.undo),
                  label: const Text('Deshacer'),
                  onPressed: _undoLast,
                ),
              FilledButton.tonal(
                onPressed: () => context.go(bank ? '/gastos' : '/inversiones/operaciones'),
                child: Text(bank ? 'Ver Este ciclo' : 'Ver las operaciones'),
              ),
              TextButton(
                key: const Key('import-another'),
                onPressed: () => setState(() {
                  _reset();
                  _step = 0;
                }),
                child: const Text('Importar otro fichero'),
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _nav({required VoidCallback back, VoidCallback? next, String? nextLabel, Key? nextKey}) =>
      Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
        OutlinedButton.icon(icon: const Icon(Icons.arrow_back), label: const Text('Atrás'), onPressed: back),
        if (next != null) FilledButton(key: nextKey, onPressed: next, child: Text(nextLabel ?? 'Siguiente')),
      ]);
}

/// Tutorial de una plataforma (`assets/tutoriales/<nombre>.md`): texto editable sin tocar código.
class TutorialText extends StatelessWidget {
  const TutorialText(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: rootBundle.loadString('assets/tutoriales/$name.md'),
        builder: (context, snap) => snap.hasData
            ? MarkdownLite(snap.data!)
            : snap.hasError
                ? const Text('No se ha podido cargar el tutorial.')
                : const LinearProgressIndicator(),
      );
}

/// Deshace un lote (con confirmación). Devuelve si se deshizo.
Future<bool> undoImport(BuildContext context, WidgetRef ref, String batchId, String name) async {
  final ok = await confirmDialog(
    context,
    title: '¿Deshacer la importación de «$name»?',
    message: 'Se borra lo nuevo que entró con ese fichero y lo que se emparejó vuelve a como estaba: los '
        'previstos, a previstos, y las posiciones iniciales sustituidas se recuperan.',
    confirmLabel: 'Deshacer',
  );
  if (!ok) return false;
  try {
    await ref.read(apiProvider).getImportsApi().undoBatch(batchId: batchId);
    gastos.refreshAll(ref);
    inv.refreshInv(ref);
    ref.invalidate(gastos.importBatchesProvider);
    if (context.mounted) gastos.showSnack(context, 'Importación deshecha');
    return true;
  } catch (e) {
    if (context.mounted) gastos.showSnack(context, apiErrorMessage(e));
    return false;
  }
}

/// Importaciones anteriores (banco y plataformas): fecha, fichero, filas y "Deshacer".
class ImportHistory extends ConsumerWidget {
  const ImportHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(gastos.importBatchesProvider).value ?? const <BatchOut>[];
    if (batches.isEmpty) return const SizedBox.shrink();
    return Card(
      key: const Key('import-history'),
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader('Importaciones anteriores'),
        for (final b in batches)
          ListRow(
            key: Key('batch-${b.id}'),
            lead: _day(b.createdAt),
            title: b.filename,
            subtitle: [
              b.kind == 'platform' ? 'Inversiones' : 'Banco',
              '${b.counts.values.fold<int>(0, (s, v) => s + v)} filas',
              '${(b.counts['new'] ?? 0)} ${b.kind == 'platform' ? 'nuevas' : 'nuevos'}',
              if (b.status == 'undone') 'deshecha',
            ].join(' · '),
            reserveAction: true,
            actions: [
              if (b.status != 'undone')
                RowAction(
                  key: Key('undo-${b.id}'),
                  icon: Icons.undo,
                  label: 'Deshacer',
                  primary: true,
                  onPressed: () => undoImport(context, ref, b.id, b.filename),
                ),
            ],
          ),
      ]),
    );
  }
}

/// "¿Cómo exporto de…?": enlaces al tutorial de cada plataforma, para los estados vacíos.
class TutorialLinks extends StatelessWidget {
  const TutorialLinks({super.key, required this.sources});
  final List<ImportSource> sources;

  @override
  Widget build(BuildContext context) => Wrap(alignment: WrapAlignment.center, spacing: Space.xs, children: [
        for (final s in sources)
          TextButton(
            key: Key('howto-${s.slug}'),
            onPressed: () => context.go('${s.isBank ? '/gastos/importar' : '/inversiones/importar'}?fuente=${s.slug}&paso=2'),
            child: Text(s == ImportSource.other ? '¿Y de otra plataforma?' : '¿Cómo exporto de ${s.label}?'),
          ),
      ]);
}

/// "2 oct 26": las importaciones pueden traer varios años.
String _day(DateTime d) => '${gastos.shortDate(d)} ${d.year % 100}';
