import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';

/// Qué líneas se enseñan: el dinero nuevo, lo que sale (ventas, retiradas y traspasos) o todo.
enum _Show { aportaciones, salidas, todo }

/// Inversiones → Aportaciones (docs/06-rediseno-ui.md §4.3): cuánto dinero nuevo metes cada mes en
/// inversiones y en ahorro, con el ritmo mensual y la racha. `destino` (`a:<activo>` o
/// `c:<cuenta>`) filtra desde el principio (p. ej. desde la ficha de una cuenta de ahorro).
class ContributionsHistoryPage extends ConsumerStatefulWidget {
  const ContributionsHistoryPage({super.key, this.destination});
  final String? destination;

  @override
  ConsumerState<ContributionsHistoryPage> createState() => _ContributionsHistoryPageState();
}

class _ContributionsHistoryPageState extends ConsumerState<ContributionsHistoryPage> {
  late String _dest = widget.destination ?? '';
  String _kind = 'todo'; // todo | inversion | ahorro
  _Show _show = _Show.aportaciones;

  bool _visible(ContributionItemOut i) {
    if (_dest.isNotEmpty && i.destination != _dest) return false;
    if (_kind != 'todo' && i.kind.value != _kind) return false;
    return switch (_show) {
      _Show.aportaciones => i.type == ContributionItemOutTypeEnum.aportacion,
      _Show.salidas => i.type == ContributionItemOutTypeEnum.retirada || i.type == ContributionItemOutTypeEnum.traspaso,
      _Show.todo => true,
    };
  }

  static String _typeLabel(ContributionItemOutTypeEnum t) => switch (t) {
        ContributionItemOutTypeEnum.aportacion => 'Aportación',
        ContributionItemOutTypeEnum.retirada => 'Venta o retirada',
        ContributionItemOutTypeEnum.traspaso => 'Traspaso (no es dinero nuevo)',
        ContributionItemOutTypeEnum.partida => 'Saldo de partida',
      };

  Future<void> _exportCsv(List<ContributionItemOut> items) async {
    String esc(String s) => '"${s.replaceAll('"', '""')}"';
    final rows = [
      'fecha;destino;tipo;importe;origen;estado',
      for (final i in items)
        [
          i.date.toIso8601String().substring(0, 10),
          esc(i.destinationLabel),
          esc(_typeLabel(i.type)),
          i.amount.replaceAll('.', ','),
          esc(i.origin),
          i.status.value,
        ].join(';'),
    ];
    try {
      await FilePicker.saveFile(
        fileName: 'faro-aportaciones.csv',
        bytes: Uint8List.fromList(utf8.encode('﻿${rows.join('\n')}')),
        mimeType: 'text/csv',
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(contributionsProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Aportaciones'), actions: [
        BarAction(
          key: const Key('open-contribution-2'),
          icon: Icons.call_split,
          label: 'Repartir una aportación',
          onPressed: () => context.go('/inversiones/aportar'),
        ),
      ]),
      body: data.when(
        loading: () => const SkeletonPage(kpis: 4),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (c) {
          final items = c.items.where(_visible).toList();
          final dests = {for (final d in c.destinations) d.key: d};
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(contributionsProvider),
            child: ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 96), children: [
              _Kpis(c: c),
              const SizedBox(height: Space.md),
              _Filters(
                destinations: c.destinations,
                dest: _dest,
                kind: _kind,
                show: _show,
                onDest: (v) => setState(() => _dest = v),
                onKind: (v) => setState(() => _kind = v),
                onShow: (v) => setState(() => _show = v),
              ),
              const SizedBox(height: Space.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.lg, Space.sm),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
                    Text('Aportaciones por mes', style: Theme.of(context).textTheme.titleMedium),
                    _MonthlyChart(c: c, dest: _dest, kind: _kind),
                    Text(
                      'Solo el dinero nuevo: las ventas, las retiradas y los traspasos entre fondos no cuentan. '
                      'La línea es tu ritmo (media de los últimos 12 meses).',
                      style: FaroText.caption(context),
                    ),
                  ]),
                ),
              ),
              if (dec(c.starting) > Decimal.zero || dec(c.withdrawn) > Decimal.zero)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.sm),
                  child: Text(
                    [
                      if (dec(c.starting) > Decimal.zero)
                        'Saldo de partida (posiciones iniciales, no son aportaciones): ${eur(c.starting)}',
                      if (dec(c.withdrawn) > Decimal.zero) 'Vendido o retirado: ${eur(c.withdrawn)}',
                    ].join(' · '),
                    style: FaroText.caption(context),
                  ),
                ),
              Row(children: [
                Expanded(child: SectionHeader('Movimientos (${items.length})', padding: const EdgeInsets.fromLTRB(Space.sm, Space.lg, Space.sm, Space.xs))),
                TextButton.icon(
                  key: const Key('export-csv'),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Exportar CSV'),
                  onPressed: items.isEmpty ? null : () => _exportCsv(items),
                ),
              ]),
              if (items.isEmpty)
                const EmptyState(
                  icon: Icons.savings_outlined,
                  title: 'Nada que enseñar con estos filtros',
                  text: 'Las compras, las aportaciones periódicas y los traspasos a tus cuentas de ahorro salen aquí.',
                )
              else
                Card(child: _GroupedList(items: items, dests: dests, trackStart: c.trackStart, typeLabel: _typeLabel)),
            ]),
          );
        },
      ),
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.c});
  final ContributionsOut c;

  @override
  Widget build(BuildContext context) {
    final big = FaroText.kpi(context);
    Widget m(String v) => MoneyText.api(v, compact: true, style: big);
    return KpiGrid(minWidth: 160, children: [
      KpiCard(label: 'Este mes', value: m(c.thisMonth), emphasis: true),
      KpiCard(label: 'Este año', value: m(c.thisYear)),
      KpiCard(label: 'Total aportado', value: m(c.total)),
      KpiCard(
        label: 'Ritmo mensual',
        value: Text('${MoneyText.format(dec(c.pace), compact: true)}/mes'),
        note: 'Media de los últimos 12 meses',
      ),
      KpiCard(
        label: 'Racha',
        valueText: '${c.streak} ${c.streak == 1 ? 'mes' : 'meses'}',
        note: 'Meses seguidos aportando',
      ),
    ]);
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.destinations,
    required this.dest,
    required this.kind,
    required this.show,
    required this.onDest,
    required this.onKind,
    required this.onShow,
  });
  final List<ContributionDestinationOut> destinations;
  final String dest, kind;
  final _Show show;
  final ValueChanged<String> onDest, onKind;
  final ValueChanged<_Show> onShow;

  @override
  Widget build(BuildContext context) => FieldRow(minWidth: 260, children: [
        SelectField<String>(
          key: const Key('contrib-dest'),
          label: 'Destino',
          value: dest,
          options: [
            const SelectOption('', 'Todos los destinos', icon: Icons.all_inclusive),
            for (final d in destinations)
              SelectOption(
                d.key,
                d.label,
                subtitle: d.kind == ContributionDestinationOutKindEnum.ahorro ? 'Cuenta de ahorro' : 'Inversión',
                icon: d.kind == ContributionDestinationOutKindEnum.ahorro ? Icons.savings_outlined : Icons.show_chart,
              ),
          ],
          onChanged: onDest,
        ),
        SegmentedField<String>(
          label: 'Dónde',
          segments: const [Segment('todo', 'Todo'), Segment('inversion', 'Inversiones'), Segment('ahorro', 'Ahorro')],
          value: kind,
          onChanged: onKind,
        ),
        SegmentedField<_Show>(
          label: 'Qué',
          segments: const [
            Segment(_Show.aportaciones, 'Aportaciones'),
            Segment(_Show.salidas, 'Salidas'),
            Segment(_Show.todo, 'Todo'),
          ],
          value: show,
          onChanged: onShow,
        ),
      ]);
}

/// Barras apiladas por mes y destino (los últimos 24 meses con datos), con la línea del ritmo.
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.c, required this.dest, required this.kind});
  final ContributionsOut c;
  final String dest, kind;

  @override
  Widget build(BuildContext context) {
    final f = context.faro;
    final dests = c.destinations
        .where((d) => (dest.isEmpty || d.key == dest) && (kind == 'todo' || d.kind.value == kind))
        .toList();
    final months = c.months.length > 24 ? c.months.sublist(c.months.length - 24) : c.months;
    return FaroBarChart(
      height: 240,
      average: dest.isEmpty && kind == 'todo' ? dec(c.pace).toDouble() : null,
      emptyText: 'Aún no hay aportaciones',
      series: [
        for (final d in dests) (id: d.key, label: d.label, color: f.seriesFor(d.key)),
      ],
      groups: [
        for (final m in months)
          BarGroup(
            monthsShortEs[m.month - 1],
            [for (final d in dests) dec(m.byDestination[d.key] ?? '0').toDouble()],
            tooltipTitle: '${monthsShortEs[m.month - 1]} ${m.year}',
            year: m.year,
          ),
      ],
    );
  }
}

/// Lista agrupada por mes; marca dónde empieza el seguimiento.
class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items, required this.dests, required this.trackStart, required this.typeLabel});
  final List<ContributionItemOut> items;
  final Map<String, ContributionDestinationOut> dests;
  final DateTime? trackStart;
  final String Function(ContributionItemOutTypeEnum) typeLabel;

  @override
  Widget build(BuildContext context) {
    final byMonth = <String, List<ContributionItemOut>>{};
    for (final i in items) {
      byMonth.putIfAbsent('${monthsShortEs[i.date.month - 1]} ${i.date.year}', () => []).add(i);
    }
    var markerShown = false;
    final children = <Widget>[];
    for (final e in byMonth.entries) {
      final total = e.value
          .where((i) => i.type == ContributionItemOutTypeEnum.aportacion)
          .fold(Decimal.zero, (s, i) => s + dec(i.amount));
      children.add(SectionHeader(e.key, trailing: Text(total > Decimal.zero ? formatEur(total) : '')));
      for (final i in e.value) {
        if (!markerShown && trackStart != null && i.date.isBefore(trackStart!)) {
          markerShown = true;
          children.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
            child: Row(spacing: Space.sm, children: [
              Icon(Icons.flag_outlined, size: 16, color: context.faro.info),
              Expanded(
                child: Text('Empieza el seguimiento (${fullDate(trackStart!)}): lo de abajo es anterior',
                    style: FaroText.caption(context)),
              ),
            ]),
          ));
        }
        final out = i.type != ContributionItemOutTypeEnum.aportacion && i.type != ContributionItemOutTypeEnum.partida;
        children.add(ListRow(
          key: Key('contrib-${i.txId ?? i.movementId}'),
          lead: dayMonth(i.date),
          leading: Icon(
            i.kind == ContributionItemOutKindEnum.ahorro ? Icons.savings_outlined : Icons.show_chart,
            color: context.faro.seriesFor(i.destination),
          ),
          title: i.destinationLabel,
          subtitle: [
            typeLabel(i.type),
            i.origin,
            if (i.status == ContributionItemOutStatusEnum.pendiente) 'pendiente de VL',
          ].join(' · '),
          trailing: Text(
            '${out ? '−' : ''}${eur(i.amount)}',
            style: TextStyle(color: out ? Theme.of(context).colorScheme.onSurfaceVariant : null),
          ),
          onTap: i.assetId != null
              ? () => context.go('/inversiones/activo/${i.assetId}')
              : () => context.go('/gastos/cuentas'),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }
}
