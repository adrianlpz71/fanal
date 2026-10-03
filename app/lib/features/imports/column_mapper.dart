import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart' show userApi;

/// Un papel que puede tener una columna del fichero (fecha, concepto, importe…).
class ColumnRole {
  const ColumnRole(this.key, this.label, {this.required = false, this.help});
  final String key;
  final String label;
  final bool required;
  final String? help;
}

/// Columnas de un extracto bancario. El concepto puede salir de dos columnas.
const bankRoles = [
  ColumnRole('date', 'Fecha', required: true),
  ColumnRole('concept', 'Concepto', required: true),
  ColumnRole('concept2', 'Concepto (2ª columna)', help: 'Si el detalle está repartido en dos columnas'),
  ColumnRole('amount', 'Importe', help: 'Con signo: negativo = sale dinero. Si hay cargo y abono por separado, déjalo vacío'),
  ColumnRole('debit', 'Cargo'),
  ColumnRole('credit', 'Abono'),
  ColumnRole('balance', 'Saldo', help: 'Opcional: sirve para comprobar que cuadra'),
];

/// Columnas de un fichero de operaciones de inversión.
const brokerRoles = [
  ColumnRole('date', 'Fecha', required: true),
  ColumnRole('key', 'Activo (ISIN o ticker)', required: true),
  ColumnRole('units', 'Participaciones', required: true),
  ColumnRole('amount', 'Importe en euros', required: true),
  ColumnRole('kind', 'Tipo de operación', help: 'Compra o venta. Si no hay, una cantidad negativa es una venta'),
  ColumnRole('fee', 'Comisión'),
  ColumnRole('name', 'Nombre del activo', help: 'Para nombrar los activos que se creen'),
  ColumnRole('ref', 'Referencia de la operación', help: 'Si existe, evita duplicados con más seguridad'),
];

/// Pide al servidor las primeras filas del fichero (y el mapeo sugerido, si lo reconoce).
Future<TableInspectOut> inspectFile(WidgetRef ref, Uint8List bytes, String name, {String kind = 'bank'}) async {
  final r = await ref.read(dioProvider).post<Map<String, dynamic>>(
        '/api/imports/inspect',
        data: FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: name), 'kind': kind}),
      );
  return TableInspectOut.fromJson(r.data!);
}

String _letter(int i) => i < 26 ? String.fromCharCode(65 + i) : 'C${i + 1}';

/// Editor de columnas: se elige la fila de cabecera y qué columna es cada cosa. Devuelve el mapeo
/// (el mismo formato que usa el servidor) con `Navigator.pop`.
class ColumnMapperPage extends StatefulWidget {
  const ColumnMapperPage({
    super.key,
    required this.title,
    required this.rows,
    required this.roles,
    this.initial,
    this.message,
    this.broker = false,
  });

  final String title;
  final List<List<String>> rows;
  final List<ColumnRole> roles;
  final Map<String, dynamic>? initial;
  final String? message;
  final bool broker;

  @override
  State<ColumnMapperPage> createState() => _ColumnMapperPageState();
}

class _ColumnMapperPageState extends State<ColumnMapperPage> {
  late int _header = (widget.initial?['header_row'] as int?) ?? _guessHeader();
  final Map<String, int?> _cols = {};
  late final _platform = TextEditingController(text: widget.initial?['platform'] as String? ?? '');
  late String _keyType = widget.initial?['key_type'] as String? ?? 'isin';
  late String _assetType = widget.initial?['asset_type'] as String? ?? 'fondo';
  late String _decimal = widget.initial?['decimal'] as String? ?? 'auto';
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.initial ?? const {};
    for (final r in widget.roles) {
      if (r.key == 'concept' || r.key == 'concept2') {
        final list = (m['concept'] as List?)?.cast<int>() ?? const [];
        _cols[r.key] = r.key == 'concept' ? list.firstOrNull : (list.length > 1 ? list[1] : null);
      } else {
        _cols[r.key] = m[r.key] as int?;
      }
    }
  }

  /// La primera fila con varias celdas con texto suele ser la cabecera.
  int _guessHeader() {
    for (var i = 0; i < widget.rows.length && i < 20; i++) {
      if (widget.rows[i].where((c) => c.trim().isNotEmpty).length >= 3) return i;
    }
    return 0;
  }

  int get _width => widget.rows.fold(0, (w, r) => r.length > w ? r.length : w);

  String _colLabel(int i) {
    final h = _header < widget.rows.length && i < widget.rows[_header].length ? widget.rows[_header][i].trim() : '';
    return h.isEmpty ? 'Columna ${_letter(i)}' : '${_letter(i)} · $h';
  }

  void _apply() {
    final missing = widget.roles.where((r) => r.required && _cols[r.key] == null).map((r) => r.label).toList();
    if (!widget.broker && _cols['amount'] == null && _cols['debit'] == null && _cols['credit'] == null) {
      missing.add('Importe (o Cargo / Abono)');
    }
    if (widget.broker && _platform.text.trim().isEmpty) missing.add('Plataforma');
    if (missing.isNotEmpty) {
      setState(() => _error = 'Falta: ${missing.join(', ')}');
      return;
    }
    final out = <String, dynamic>{'header_row': _header};
    for (final e in _cols.entries) {
      if (e.key == 'concept' || e.key == 'concept2') continue;
      if (e.value != null) out[e.key] = e.value;
    }
    if (!widget.broker) {
      out['concept'] = [_cols['concept'], if (_cols['concept2'] != null) _cols['concept2']];
    } else {
      out.addAll({'platform': _platform.text.trim(), 'key_type': _keyType, 'asset_type': _assetType, 'decimal': _decimal});
    }
    Navigator.of(context).pop(out);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final assigned = {for (final e in _cols.entries) if (e.value != null) e.value!: e.key};
    final sample = widget.rows.skip(_header + 1).where((r) => r.any((c) => c.trim().isNotEmpty)).take(6).toList();
    return Scaffold(
      appBar: FaroAppBar(title: PageTitle(widget.title)),
      body: FormListView(children: [
        if (widget.message != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Fanal no reconoce este formato'),
              subtitle: Text('Dile qué columna es cada cosa. ${widget.message}'),
            ),
          ),
        SelectField<int>(
          key: const Key('mapper-header'),
          label: 'Fila de cabecera',
          helper: 'La fila con los nombres de las columnas',
          value: _header,
          options: [
            for (var i = 0; i < widget.rows.length && i < 20; i++)
              SelectOption(i, 'Fila ${i + 1}', subtitle: widget.rows[i].where((c) => c.trim().isNotEmpty).join(' · ')),
          ],
          onChanged: (v) => setState(() => _header = v),
        ),
        // Vista previa con las columnas asignadas resaltadas
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              columns: [
                for (var i = 0; i < _width; i++)
                  DataColumn(
                    label: Text(
                      assigned[i] == null
                          ? _colLabel(i)
                          : '${_colLabel(i)}\n→ ${widget.roles.firstWhere((r) => r.key == assigned[i]).label}',
                      style: TextStyle(color: assigned[i] == null ? null : cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
              rows: [
                for (final r in sample)
                  DataRow(cells: [for (var i = 0; i < _width; i++) DataCell(Text(i < r.length ? r[i] : ''))]),
              ],
            ),
          ),
        ),
        if (widget.broker) ...[
          FaroTextField(
            key: const Key('mapper-platform'),
            label: 'Plataforma',
            controller: _platform,
            helper: 'Se crea en Fanal si no existe',
          ),
          SegmentedField<String>(
            label: 'Los activos se identifican',
            segments: const [Segment('isin', 'Por ISIN'), Segment('ticker', 'Por ticker')],
            value: _keyType,
            onChanged: (v) => setState(() => _keyType = v),
          ),
          SelectField<String>(
            label: 'Tipo de activo (para los que se creen)',
            value: _assetType,
            options: const [
              SelectOption('fondo', 'Fondo'),
              SelectOption('etf', 'ETF'),
              SelectOption('accion', 'Acción'),
              SelectOption('cripto', 'Cripto'),
            ],
            onChanged: (v) => setState(() => _assetType = v),
          ),
          SegmentedField<String>(
            label: 'Separador decimal',
            segments: const [Segment('auto', 'Automático'), Segment('comma', 'Coma (1.234,56)'), Segment('point', 'Punto (1,234.56)')],
            value: _decimal,
            onChanged: (v) => setState(() => _decimal = v),
          ),
        ],
        Text('Columnas', style: tt.titleMedium),
        for (final role in widget.roles)
          SelectField<int?>(
            key: Key('mapper-${role.key}'),
            label: role.required ? '${role.label} *' : role.label,
            helper: role.help,
            value: _cols[role.key],
            emptyText: '—',
            options: [
              const SelectOption<int?>(null, '— (ninguna)'),
              for (var i = 0; i < _width; i++) SelectOption<int?>(i, _colLabel(i)),
            ],
            onChanged: (v) => setState(() => _cols[role.key] = v),
          ),
        if (_error != null) ErrorText(_error),
        FilledButton(key: const Key('mapper-apply'), onPressed: _apply, child: const Text('Usar estas columnas')),
      ]),
    );
  }
}

/// Selector de formato guardado (o automático), con opción de borrarlo. Igual en banco y broker.
class ProfilePicker extends ConsumerWidget {
  const ProfilePicker({super.key, required this.provider, required this.value, required this.onChanged, this.autoLabel = 'Automático'});
  final FutureProvider<List<BankProfileOut>> provider;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String autoLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(provider).value ?? const <BankProfileOut>[];
    if (profiles.isEmpty) return const SizedBox.shrink();
    final current = profiles.where((p) => p.id == value).firstOrNull;
    return Row(spacing: FaroTheme.fieldGap / 2, children: [
      Expanded(
        child: SelectField<String?>(
          key: const Key('profile-picker'),
          label: 'Formato del fichero',
          value: current?.id,
          emptyText: autoLabel,
          options: [
            SelectOption<String?>(null, autoLabel),
            for (final p in profiles) SelectOption<String?>(p.id, p.name, subtitle: 'Formato guardado'),
          ],
          onChanged: onChanged,
        ),
      ),
      if (current != null)
        IconButton(
          tooltip: 'Borrar este formato',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final ok = await confirmDialog(context, title: '¿Borrar el formato «${current.name}»?',
                message: 'Los ficheros ya importados no cambian.');
            if (!ok) return;
            await ref.read(apiProvider).getImportsApi().deleteProfile(profileId: current.id);
            ref.invalidate(provider);
            onChanged(null);
          },
        ),
    ]);
  }
}

final bankProfilesProvider = FutureProvider<List<BankProfileOut>>(
    (ref) async => (await userApi(ref).getImportsApi().listProfiles(kind: 'bank')).data!);
final brokerProfilesProvider = FutureProvider<List<BankProfileOut>>(
    (ref) async => (await userApi(ref).getImportsApi().listProfiles(kind: 'broker')).data!);
