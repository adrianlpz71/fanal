import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../dates.dart';
import '../money.dart';
import '../tokens.dart';
import 'ticks.dart';

export 'ticks.dart';

/// Gráficas de Faro sobre `fl_chart`, con un comportamiento común: ejes con valores redondos y
/// € compactos, eje X de fechas sin repetidos, tooltip con desglose, leyenda con el valor actual
/// que activa u oculta cada serie, selector de periodo, estado de "pocos datos", tabla de datos
/// accesible y modo privacidad (sin cifras en ejes ni tooltips).

class ChartPoint {
  const ChartPoint(this.x, this.y);

  /// Punto de una serie temporal.
  ChartPoint.at(DateTime d, this.y) : x = dayNumber(d);
  final double x;
  final double y;
}

class ChartSeries {
  const ChartSeries({
    required this.id,
    required this.label,
    required this.points,
    this.color,
    this.dashed = false,
    this.stepped = false,
    this.width = 2.5,
    this.area = false,
    this.showInTooltip = true,
    this.showInLegend = true,
    this.overlay = false,
  });
  final String id;
  final String label;
  final List<ChartPoint> points;
  final Color? color;
  final bool dashed, stepped, area, showInTooltip, showInLegend;

  /// En una gráfica apilada, se dibuja con sus propios valores (sin sumar ni relleno): p. ej. la
  /// línea del patrimonio neto sobre las áreas de lo que lo compone.
  final bool overlay;
  final double width;
}

/// Eje X: fechas (días) o numérico (edades, años…).
class ChartXAxis {
  const ChartXAxis.dates()
      : dates = true,
        format = null,
        interval = null;
  const ChartXAxis.numeric({required String Function(double) this.format, this.interval}) : dates = false;
  final bool dates;
  final String Function(double)? format;
  final double? interval;

  String label(double x) => dates ? fullDate(dayFromNumber(x)) : format!(x);
}

/// Línea vertical u horizontal con etiqueta (edad objetivo, inicio del seguimiento…).
class ChartMarker {
  const ChartMarker(this.value, this.label, {this.color});
  final double value;
  final String label;
  final Color? color;
}

/// Punto destacado en una gráfica de líneas (p. ej. dónde la proyección cruza lo que necesitas).
class ChartDot {
  const ChartDot(this.x, this.y, {this.color});
  final double x, y;
  final Color? color;
}

String _money(double v) => privacyMode ? '••••$nbsp€' : formatEur(Decimal.parse(v.toStringAsFixed(2)));

Color _seriesColor(BuildContext context, ChartSeries s, int i) =>
    s.color ?? context.faro.series[i % context.faro.series.length];

/// Leyenda: color, nombre y valor actual; tocarla oculta o muestra la serie.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items, this.hidden = const {}, this.onToggle});
  final List<({String id, String label, Color color, String? value, bool dashed})> items;
  final Set<String> hidden;
  final ValueChanged<String>? onToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Wrap(spacing: Space.md, runSpacing: Space.xs, children: [
      for (final it in items)
        Semantics(
          button: onToggle != null,
          toggled: !hidden.contains(it.id),
          child: InkWell(
            key: Key('legend-${it.id}'),
            borderRadius: BorderRadius.circular(Radii.sm),
            onTap: onToggle == null ? null : () => onToggle!(it.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xs),
              child: Opacity(
                opacity: hidden.contains(it.id) ? 0.4 : 1,
                child: Row(mainAxisSize: MainAxisSize.min, spacing: Space.sm - 2, children: [
                  Container(
                    width: 14,
                    height: it.dashed ? 3 : 10,
                    decoration: BoxDecoration(color: it.color, borderRadius: BorderRadius.circular(2)),
                  ),
                  Flexible(child: Text(it.label, style: tt.bodySmall)), // largo: salta de línea, no se sale
                  if (it.value != null)
                    Text(it.value!,
                        style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontFeatures: FaroText.tabular)),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}

/// Selector de periodo (1M · 3M · 6M · YTD · 1A · Todo).
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.value, required this.onChanged, this.options = ChartPeriod.values});
  final ChartPeriod value;
  final ValueChanged<ChartPeriod> onChanged;
  final List<ChartPeriod> options;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        // Estrecho (móvil): ocupa todo el ancho con los segmentos iguales y más justos, sin
        // desplazamiento lateral ni segmentos cortados
        final narrow = box.maxWidth < options.length * 88;
        return SegmentedButton<ChartPeriod>(
          key: const Key('period-selector'),
          showSelectedIcon: !narrow, // ✓ en el elegido cuando cabe (no solo el color)
          expandedInsets: narrow ? EdgeInsets.zero : null,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: narrow ? const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 2)) : null,
          ),
          segments: [
            for (final p in options) ButtonSegment(value: p, label: Text(chartPeriodLabels[p]!, softWrap: false)),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        );
      });
}

/// Caja de "aún no hay datos" con la misma altura que tendría la gráfica.
class ChartEmpty extends StatelessWidget {
  const ChartEmpty({super.key, required this.height, required this.text});
  final double height;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        padding: const EdgeInsets.all(Space.lg),
        child: Row(mainAxisSize: MainAxisSize.min, spacing: Space.sm, children: [
          Icon(Icons.insights_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
          Flexible(child: Text(text, style: FaroText.caption(context), textAlign: TextAlign.center)),
        ]),
      );
}

/// Tabla con los datos de la gráfica (plegada), para leerlos con precisión o con lector de pantalla.
class ChartDataTable extends StatelessWidget {
  const ChartDataTable({super.key, required this.columns, required this.rows});
  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('chart-data'),
          tilePadding: EdgeInsets.zero,
          dense: true,
          title: Text('Ver los datos', style: Theme.of(context).textTheme.bodySmall),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 36,
                columns: [
                  for (final (i, c) in columns.indexed) DataColumn(label: Text(c), numeric: i > 0),
                ],
                rows: [
                  for (final r in rows)
                    DataRow(cells: [
                      for (final c in r) DataCell(Text(c, style: const TextStyle(fontFeatures: FaroText.tabular))),
                    ]),
                ],
              ),
            ),
          ],
        ),
      );
}

FlTitlesData _titles({
  required BuildContext context,
  required AxisScale y,
  required String Function(double) yFormat,
  required Widget Function(double, TitleMeta) bottom,
  double bottomInterval = 1,
  double leftReserved = 60,
  double bottomReserved = 26,
}) {
  final style = FaroText.caption(context).copyWith(fontSize: 11, fontFeatures: FaroText.tabular);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: leftReserved,
        interval: y.interval,
        getTitlesWidget: (v, meta) => y.isTick(v)
            ? SideTitleWidget(meta: meta, child: Text(yFormat(v), style: style, softWrap: false))
            : const SizedBox.shrink(),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: bottomReserved,
        interval: bottomInterval,
        getTitlesWidget: bottom,
      ),
    ),
  );
}

/// Gráfica de líneas (o de áreas apiladas con [stacked]) con todo el comportamiento común.
class FaroLineChart extends StatefulWidget {
  const FaroLineChart({
    super.key,
    required this.series,
    this.xAxis = const ChartXAxis.dates(),
    this.height = 240,
    this.stacked = false,
    this.includeZero = false,
    this.periods = false,
    this.initialPeriod = ChartPeriod.all,
    this.yFormat = compactEur,
    this.valueFormat = _money,
    this.bands = const [],
    this.verticalMarkers = const [],
    this.horizontalMarkers = const [],
    this.dots = const [],
    this.minPoints = 2,
    this.emptyText = 'Aún no hay datos suficientes para dibujar la gráfica',
    this.legend = true,
    this.table = true,
    this.semanticLabel,
  });

  final List<ChartSeries> series;
  final ChartXAxis xAxis;
  final double height;
  final bool stacked, includeZero, periods, legend, table;
  final ChartPeriod initialPeriod;
  final String Function(double) yFormat;
  final String Function(double) valueFormat;

  /// Relleno entre dos series (p. ej. banda pesimista–optimista): ids (desde, hasta).
  final List<(String, String)> bands;
  final List<ChartMarker> verticalMarkers, horizontalMarkers;
  final List<ChartDot> dots;
  final int minPoints;
  final String emptyText;
  final String? semanticLabel;

  @override
  State<FaroLineChart> createState() => _FaroLineChartState();
}

class _FaroLineChartState extends State<FaroLineChart> {
  late ChartPeriod _period = widget.initialPeriod;
  final _hidden = <String>{};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final start = widget.periods && widget.xAxis.dates ? periodStart(_period, DateTime.now()) : null;
    final from = start == null ? null : dayNumber(start);
    List<ChartPoint> inRange(List<ChartPoint> p) => from == null ? p : p.where((x) => x.x >= from).toList();

    final all = [
      for (final (i, s) in widget.series.indexed) (s: s, color: _seriesColor(context, s, i), pts: inRange(s.points)),
    ];
    final visible = all.where((e) => !_hidden.contains(e.s.id)).toList();
    final enough = all.any((e) => e.pts.length >= widget.minPoints);

    final header = <Widget>[
      if (widget.periods)
        Align(
          alignment: Alignment.centerRight,
          child: PeriodSelector(value: _period, onChanged: (p) => setState(() => _period = p)),
        ),
    ];
    if (!enough) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
        ...header,
        ChartEmpty(height: widget.height, text: widget.emptyText),
      ]);
    }

    // Apilado: cada serie se dibuja sobre la suma de las anteriores (mismas x en todas)
    final plotted = <List<ChartPoint>>[];
    if (widget.stacked) {
      final acc = <double, double>{};
      for (final e in visible) {
        if (e.s.overlay) {
          plotted.add(e.pts);
          continue;
        }
        plotted.add([
          for (final p in e.pts) ChartPoint(p.x, (acc[p.x] = (acc[p.x] ?? 0) + p.y)),
        ]);
      }
    } else {
      plotted.addAll(visible.map((e) => e.pts));
    }
    final ys = [for (final p in plotted) ...p.map((e) => e.y), for (final m in widget.horizontalMarkers) m.value];
    final xs = [for (final p in plotted) ...p.map((e) => e.x)];
    final y = ys.isEmpty
        ? niceScale(0, 1)
        : niceScale(ys.reduce(math.min), ys.reduce(math.max), includeZero: widget.includeZero || widget.stacked);
    final minX = xs.isEmpty ? 0.0 : xs.reduce(math.min);
    final maxX = xs.isEmpty ? 1.0 : xs.reduce(math.max);
    String yFmt(double v) => privacyMode ? '•••' : widget.yFormat(v);
    final idIndex = {for (final (i, e) in visible.indexed) e.s.id: i};

    final legendItems = [
      for (final e in all)
        if (e.s.showInLegend)
          (
            id: e.s.id,
            label: e.s.label,
            color: e.color,
            dashed: e.s.dashed || e.s.overlay, // una línea, no un área
            value: e.pts.isEmpty ? null : widget.valueFormat(e.pts.last.y),
          ),
    ];

    final chart = LayoutBuilder(builder: (context, box) {
      final plotW = math.max(80.0, box.maxWidth - 64);
      DateTicks? dt;
      Set<int>? tickDays;
      if (widget.xAxis.dates) {
        dt = dateTicks(dayFromNumber(minX), dayFromNumber(maxX), plotW);
        tickDays = {for (final d in dt.ticks) dayNumber(d).round()};
      }
      final labelStyle = FaroText.caption(context).copyWith(fontSize: 11);
      Widget bottom(double v, TitleMeta meta) {
        if (widget.xAxis.dates) {
          if (!tickDays!.contains(v.round()) || (v - v.roundToDouble()).abs() > 1e-6) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
            child: Text(dt!.label(dayFromNumber(v)), style: labelStyle, softWrap: false),
          );
        }
        final iv = widget.xAxis.interval ?? 1;
        final k = v / iv;
        if ((k - k.roundToDouble()).abs() > 1e-6) return const SizedBox.shrink();
        return SideTitleWidget(
          meta: meta,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          child: Text(widget.xAxis.format!(v), style: labelStyle, softWrap: false),
        );
      }

      final stack = [for (final (i, e) in visible.indexed) if (!e.s.overlay) i];
      final bars = <LineChartBarData>[
        for (final (i, e) in visible.indexed)
          LineChartBarData(
            spots: [for (final p in plotted[i]) FlSpot(p.x, p.y)],
            color: e.color,
            barWidth: e.s.width,
            isStepLineChart: e.s.stepped,
            dashArray: e.s.dashed ? const [5, 4] : null,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: (widget.stacked && stack.isNotEmpty && i == stack.first) || (!widget.stacked && e.s.area),
              color: e.color.withValues(alpha: widget.stacked ? 0.55 : 0.18),
            ),
          ),
        // Puntos destacados: una "serie" de un solo punto, sin línea (van después de las series)
        for (final d in widget.dots)
          if (d.x >= minX && d.x <= maxX)
            LineChartBarData(
              spots: [FlSpot(d.x, d.y)],
              barWidth: 0,
              color: Colors.transparent,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 5,
                  color: d.color ?? cs.primary,
                  strokeWidth: 2,
                  strokeColor: cs.surface,
                ),
              ),
            ),
      ];
      final between = <BetweenBarsData>[
        if (widget.stacked)
          for (var k = 1; k < stack.length; k++)
            BetweenBarsData(
              fromIndex: stack[k - 1],
              toIndex: stack[k],
              color: visible[stack[k]].color.withValues(alpha: 0.55),
            ),
        for (final (a, b) in widget.bands)
          if (idIndex[a] != null && idIndex[b] != null)
            BetweenBarsData(
              fromIndex: idIndex[a]!,
              toIndex: idIndex[b]!,
              color: visible[idIndex[a]!].color.withValues(alpha: 0.18),
            ),
      ];
      return SizedBox(
        height: widget.height,
        child: RepaintBoundary(child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: y.min,
            maxY: y.max,
            lineBarsData: bars,
            betweenBarsData: between,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: y.interval,
              getDrawingHorizontalLine: (_) => FlLine(color: cs.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _titles(context: context, y: y, yFormat: yFmt, bottom: bottom),
            extraLinesData: ExtraLinesData(
              verticalLines: [
                for (final (mi, m) in widget.verticalMarkers.indexed)
                  VerticalLine(
                    x: m.value,
                    color: m.color ?? cs.onSurfaceVariant,
                    strokeWidth: 1.5,
                    dashArray: const [4, 4],
                    label: VerticalLineLabel(
                      show: true,
                      // Cerca del borde derecho, a la izquierda de la línea (si no, se corta); la
                      // segunda marca, abajo, para que dos etiquetas cercanas no se pisen
                      alignment: switch ((maxX > minX && (m.value - minX) / (maxX - minX) > 0.8, mi.isOdd)) {
                        (true, false) => Alignment.topLeft,
                        (false, false) => Alignment.topRight,
                        (true, true) => Alignment.bottomLeft,
                        (false, true) => Alignment.bottomRight,
                      },
                      style: labelStyle.copyWith(color: m.color ?? cs.onSurfaceVariant),
                      labelResolver: (_) => m.label,
                    ),
                  ),
              ],
              horizontalLines: [
                for (final m in widget.horizontalMarkers)
                  HorizontalLine(
                    y: m.value,
                    color: m.color ?? cs.onSurfaceVariant,
                    strokeWidth: 1.5,
                    dashArray: const [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: labelStyle.copyWith(color: m.color ?? cs.onSurfaceVariant),
                      labelResolver: (_) => privacyMode ? m.label : '${m.label} · ${widget.valueFormat(m.value)}',
                    ),
                  ),
              ],
            ),
            lineTouchData: LineTouchData(
              enabled: !privacyMode,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => cs.inverseSurface,
                maxContentWidth: 260,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (spots) {
                  final sorted = [...spots]..sort((a, b) => a.barIndex.compareTo(b.barIndex));
                  final first = sorted.isEmpty ? null : sorted.first;
                  return [
                    for (final s in spots)
                      () {
                        if (s.barIndex >= visible.length) return null; // un punto destacado
                        final e = visible[s.barIndex];
                        if (!e.s.showInTooltip) return null;
                        final raw = e.pts[s.spotIndex].y;
                        final head = identical(s, first) ? '${widget.xAxis.label(s.x)}\n' : '';
                        return LineTooltipItem(
                          '$head${e.s.label}: ${widget.valueFormat(raw)}',
                          TextStyle(color: cs.onInverseSurface, fontSize: 12, fontFeatures: FaroText.tabular),
                        );
                      }(),
                  ];
                },
              ),
            ),
          ),
          duration: Duration.zero,
        )),
      );
    });

    final lastX = xs.isEmpty ? null : maxX;
    final summary = widget.semanticLabel ??
        'Gráfica. ${[for (final i in legendItems) '${i.label}: ${i.value ?? 'sin datos'}'].join('. ')}'
            '${lastX == null ? '' : '. Último dato: ${widget.xAxis.label(lastX)}'}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
      ...header,
      Semantics(label: summary, excludeSemantics: true, child: chart),
      if (widget.legend)
        ChartLegend(
          items: legendItems,
          hidden: _hidden,
          onToggle: all.length < 2
              ? null
              : (id) => setState(() => _hidden.contains(id) ? _hidden.remove(id) : _hidden.add(id)),
        ),
      if (widget.table) _table(all),
    ]);
  }

  Widget _table(List<({ChartSeries s, Color color, List<ChartPoint> pts})> all) {
    final xs = <double>{for (final e in all) ...e.pts.map((p) => p.x)}.toList()..sort();
    final byX = [for (final e in all) {for (final p in e.pts) p.x: p.y}];
    // Como mucho 60 filas: las más recientes primero
    final shown = xs.reversed.take(60).toList();
    return ChartDataTable(
      columns: [widget.xAxis.dates ? 'Fecha' : '', for (final e in all) e.s.label],
      rows: [
        for (final x in shown)
          [
            widget.xAxis.label(x),
            for (final m in byX) m[x] == null ? '' : widget.valueFormat(m[x]!),
          ],
      ],
    );
  }
}

/// Grupo de barras (una por categoría del eje X: un mes, un ciclo…).
class BarGroup {
  const BarGroup(this.label, this.values, {this.tooltipTitle, this.year});
  final String label;

  /// Año del grupo, si el eje son meses: se pinta bajo la etiqueta cuando cambia (sin meses repetidos
  /// que no se sepa de qué año son).
  final int? year;

  /// Un valor por serie (mismo orden que `FaroBarChart.series`). Puede ser negativo.
  final List<double> values;
  final String? tooltipTitle;
}

/// Barras apiladas (o +/−: los negativos se apilan hacia abajo) con tooltip de desglose.
class FaroBarChart extends StatefulWidget {
  const FaroBarChart({
    super.key,
    required this.groups,
    required this.series,
    this.height = 240,
    this.yFormat = compactEur,
    this.valueFormat = _money,
    this.average,
    this.legend = true,
    this.table = true,
    this.emptyText = 'Aún no hay datos para esta gráfica',
  });
  final List<BarGroup> groups;
  final List<({String id, String label, Color? color})> series;
  final double height;
  final String Function(double) yFormat, valueFormat;

  /// Línea horizontal de la media (p. ej. ritmo mensual).
  final double? average;
  final bool legend, table;
  final String emptyText;

  @override
  State<FaroBarChart> createState() => _FaroBarChartState();
}

class _FaroBarChartState extends State<FaroBarChart> {
  final _hidden = <String>{};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.groups.isEmpty) return ChartEmpty(height: widget.height, text: widget.emptyText);
    final colors = [
      for (final (i, s) in widget.series.indexed) s.color ?? context.faro.series[i % context.faro.series.length],
    ];
    final on = [for (final s in widget.series) !_hidden.contains(s.id)];
    var lo = 0.0, hi = 0.0;
    for (final g in widget.groups) {
      var pos = 0.0, neg = 0.0;
      for (final (i, v) in g.values.indexed) {
        if (!on[i]) continue;
        if (v >= 0) {
          pos += v;
        } else {
          neg += v;
        }
      }
      hi = math.max(hi, pos);
      lo = math.min(lo, neg);
    }
    if (widget.average != null) hi = math.max(hi, widget.average!);
    final y = niceScale(lo, hi, includeZero: true);
    String yFmt(double v) => privacyMode ? '•••' : widget.yFormat(v);
    final labelStyle = FaroText.caption(context).copyWith(fontSize: 11);

    final withYears = widget.groups.any((g) => g.year != null);
    final chart = LayoutBuilder(builder: (context, box) {
      final n = widget.groups.length;
      final slot = (box.maxWidth - 64) / n;
      final barW = (slot * 0.6).clamp(4.0, 36.0);
      final every = math.max(1, (64 / slot).ceil()); // etiquetas que quepan
      return SizedBox(
        height: widget.height,
        child: RepaintBoundary(child: BarChart(
          BarChartData(
            minY: y.min,
            maxY: y.max,
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: y.interval,
              getDrawingHorizontalLine: (_) => FlLine(color: cs.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              context: context,
              y: y,
              yFormat: yFmt,
              bottomReserved: withYears ? 40 : 26,
              bottom: (v, meta) {
                final i = v.round();
                if (i < 0 || i >= n || i % every != 0) return const SizedBox.shrink();
                final g = widget.groups[i];
                final year = g.year != null && (i < every || widget.groups[i - every].year != g.year) ? g.year : null;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(year == null ? g.label : '${g.label}\n$year', style: labelStyle, textAlign: TextAlign.center),
                );
              },
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              if (widget.average != null)
                HorizontalLine(
                  y: widget.average!,
                  color: cs.onSurfaceVariant,
                  strokeWidth: 1.5,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    // Con fondo: las barras no lo tapan
                    style: labelStyle.copyWith(backgroundColor: cs.surfaceContainerLow),
                    labelResolver: (_) => privacyMode ? ' Media ' : ' Media ${widget.valueFormat(widget.average!)} ',
                  ),
                ),
            ]),
            barTouchData: BarTouchData(
              enabled: !privacyMode,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => cs.inverseSurface,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, gi, rod, ri) {
                  final g = widget.groups[gi];
                  final lines = [
                    g.tooltipTitle ?? g.label,
                    for (final (i, v) in g.values.indexed)
                      if (on[i] && v != 0) '${widget.series[i].label}: ${widget.valueFormat(v)}',
                    if (on.where((x) => x).length > 1)
                      'Total: ${widget.valueFormat([for (final (i, v) in g.values.indexed) if (on[i]) v].fold(0.0, (a, b) => a + b))}',
                  ];
                  return BarTooltipItem(lines.join('\n'),
                      TextStyle(color: cs.onInverseSurface, fontSize: 12, fontFeatures: FaroText.tabular));
                },
              ),
            ),
            barGroups: [
              for (final (gi, g) in widget.groups.indexed)
                () {
                  var pos = 0.0, neg = 0.0;
                  final items = <BarChartRodStackItem>[];
                  for (final (i, v) in g.values.indexed) {
                    if (!on[i] || v == 0) continue;
                    if (v > 0) {
                      items.add(BarChartRodStackItem(pos, pos + v, colors[i]));
                      pos += v;
                    } else {
                      items.add(BarChartRodStackItem(neg + v, neg, colors[i]));
                      neg += v;
                    }
                  }
                  return BarChartGroupData(x: gi, barRods: [
                    BarChartRodData(
                      fromY: neg,
                      toY: pos,
                      width: barW,
                      rodStackItems: items,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ]);
                }(),
            ],
          ),
          duration: Duration.zero,
        )),
      );
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
      Semantics(
        label: 'Gráfica de barras: ${widget.groups.length} ${widget.groups.length == 1 ? 'grupo' : 'grupos'}',
        excludeSemantics: true,
        child: chart,
      ),
      if (widget.legend && widget.series.length > 1)
        ChartLegend(
          items: [
            for (final (i, s) in widget.series.indexed)
              (id: s.id, label: s.label, color: colors[i], value: null, dashed: false),
          ],
          hidden: _hidden,
          onToggle: (id) => setState(() => _hidden.contains(id) ? _hidden.remove(id) : _hidden.add(id)),
        ),
      if (widget.table)
        ChartDataTable(
          columns: ['', for (final s in widget.series) s.label],
          rows: [
            for (final g in widget.groups.reversed)
              [g.tooltipTitle ?? g.label, for (final v in g.values) widget.valueFormat(v)],
          ],
        ),
    ]);
  }
}

/// Tramo de un donut.
class DonutSlice {
  const DonutSlice({required this.id, required this.label, required this.value, this.color});
  final String id;
  final String label;
  final double value;
  final Color? color;
}

/// Donut con el total en el centro y leyenda con valor y %.
class FaroDonut extends StatefulWidget {
  const FaroDonut({
    super.key,
    required this.slices,
    this.center,
    this.centerCaption,
    this.size = 200,
    this.valueFormat = _money,
  });
  final List<DonutSlice> slices;
  final String? center;
  final String? centerCaption;
  final double size;
  final String Function(double) valueFormat;

  @override
  State<FaroDonut> createState() => _FaroDonutState();
}

class _FaroDonutState extends State<FaroDonut> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final total = widget.slices.fold<double>(0, (s, x) => s + math.max(0, x.value));
    final colors = [
      for (final (i, s) in widget.slices.indexed) s.color ?? context.faro.series[i % context.faro.series.length],
    ];
    if (total <= 0) return ChartEmpty(height: widget.size, text: 'Sin datos para repartir');
    String pctOf(double v) => '${(v / total * 100).toStringAsFixed(1).replaceAll('.', ',')} %';
    final tt = Theme.of(context).textTheme;
    final donut = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(alignment: Alignment.center, children: [
        RepaintBoundary(child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: widget.size * 0.32,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(
              touchCallback: (e, r) => setState(() => _touched = r?.touchedSection?.touchedSectionIndex),
            ),
            sections: [
              for (final (i, s) in widget.slices.indexed)
                if (s.value > 0)
                  PieChartSectionData(
                    value: s.value,
                    color: colors[i],
                    radius: _touched == i ? widget.size * 0.17 : widget.size * 0.14,
                    showTitle: false,
                  ),
            ],
          ),
          duration: Duration.zero,
        )),
        Column(mainAxisSize: MainAxisSize.min, children: [
          if (widget.center != null)
            Text(widget.center!, style: FaroText.kpi(context).copyWith(fontSize: widget.size * 0.1)),
          if (widget.centerCaption != null) Text(widget.centerCaption!, textAlign: TextAlign.center, style: FaroText.caption(context)),
        ]),
      ]),
    );
    final legend = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, s) in widget.slices.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(spacing: Space.sm, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
            Expanded(child: Text(s.label, style: tt.bodyMedium)),
            Text(widget.valueFormat(s.value), style: tt.bodyMedium?.copyWith(fontFeatures: FaroText.tabular)),
            SizedBox(
              width: 56,
              child: Text(pctOf(s.value),
                  textAlign: TextAlign.end, style: FaroText.caption(context).copyWith(fontFeatures: FaroText.tabular)),
            ),
          ]),
        ),
    ]);
    return Semantics(
      label: 'Reparto: ${[for (final s in widget.slices) '${s.label} ${pctOf(s.value)}'].join(', ')}',
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth >= widget.size + 260
            ? Row(spacing: Space.xl, children: [donut, Expanded(child: legend)])
            : Column(spacing: Space.lg, children: [donut, legend]),
      ),
    );
  }
}

/// Minigráfica sin ejes (tendencia en una tarjeta o una fila).
class Sparkline extends StatelessWidget {
  const Sparkline(this.values, {super.key, this.color, this.height = 32, this.width = 96});
  final List<double> values;
  final Color? color;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height, width: width);
    final c = color ?? Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: width,
        child: RepaintBoundary(child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v)],
                color: c,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.12)),
              ),
            ],
          ),
          duration: Duration.zero,
        )),
      ),
    );
  }
}

/// Celda del mapa año × mes.
class HeatCell {
  const HeatCell({this.ret, this.gain, this.contributed});

  /// Rentabilidad del mes en tanto por uno.
  final double? ret;
  final double? gain;
  final double? contributed;
}

/// Mapa de rentabilidad año × mes: verde si sube, rojo si baja (la intensidad, según el tamaño),
/// con el total de cada año al final y tooltip con %, € y aportado.
class MonthHeatmap extends StatelessWidget {
  const MonthHeatmap({super.key, required this.cells, this.yearTotals = const {}});
  final Map<int, Map<int, HeatCell>> cells;
  final Map<int, double?> yearTotals;

  @override
  Widget build(BuildContext context) {
    final f = context.faro;
    final cs = Theme.of(context).colorScheme;
    final years = cells.keys.toList()..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) return const ChartEmpty(height: 120, text: 'Aún no hay meses con rentabilidad');
    final maxAbs = [
      for (final m in cells.values)
        for (final c in m.values)
          if (c.ret != null) c.ret!.abs(),
    ].fold<double>(0.01, math.max);
    String pctS(double v) {
      final s = (v * 100).toStringAsFixed(1);
      if (s == '0.0' || s == '-0.0') return '0,0 %'; // nada de "−0,0"
      return '${v > 0 ? '+' : ''}${withMinus(s.replaceAll('.', ','))} %';
    }
    Color fill(double? r) {
      if (r == null) return cs.surfaceContainerHighest.withValues(alpha: 0.4);
      final t = (r.abs() / maxAbs).clamp(0.15, 1.0);
      return (r >= 0 ? f.gain : f.loss).withValues(alpha: 0.18 + 0.62 * t);
    }

    final small = FaroText.caption(context).copyWith(fontSize: 11, fontFeatures: FaroText.tabular);
    Widget cell(int y, int m) {
      final c = cells[y]?[m];
      final r = c?.ret;
      final tip = c == null
          ? '${monthsShortEs[m - 1]} $y: sin datos'
          : [
              '${monthsShortEs[m - 1]} $y',
              if (r != null) pctS(r),
              if (c.gain != null && !privacyMode) 'Ganancia ${_money(c.gain!)}',
              if (c.contributed != null && !privacyMode) 'Aportado ${_money(c.contributed!)}',
            ].join('\n');
      return Expanded(
        child: Tooltip(
          message: tip,
          child: Container(
            height: 34,
            margin: const EdgeInsets.all(1.5),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fill(r), borderRadius: BorderRadius.circular(4)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(r == null ? '' : pctS(r).replaceAll(' %', ''), style: small.copyWith(color: cs.onSurface)),
            ),
          ),
        ),
      );
    }

    Widget total(int y) => SizedBox(
          width: 64,
          child: Center(
            child: Text(
              yearTotals[y] == null ? '—' : pctS(yearTotals[y]!),
              style: small.copyWith(
                fontWeight: FontWeight.w700,
                color: yearTotals[y] == null ? null : (yearTotals[y]! >= 0 ? f.gain : f.loss),
              ),
            ),
          ),
        );
    // Un bloque de meses [from, to] con su cabecera; el total del año va en el último bloque (en el
    // primero queda el hueco para que las columnas cuadren).
    Widget block(int from, int to, {required bool withTotal}) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const SizedBox(width: 44),
              for (var m = from; m <= to; m++) Expanded(child: Center(child: Text(monthsShortEs[m - 1], style: small))),
              SizedBox(width: 64, child: withTotal ? Center(child: Text('Año', style: small)) : null),
            ]),
            for (final y in years)
              Row(children: [
                SizedBox(width: 44, child: Text('$y', style: small)),
                for (var m = from; m <= to; m++) cell(y, m),
                withTotal ? total(y) : const SizedBox(width: 64),
              ]),
          ],
        );

    // En pantallas estrechas el año se parte en dos medios (ene–jun y jul–dic): nada queda cortado
    // ni escondido tras un scroll lateral.
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 560
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
              block(1, 6, withTotal: false),
              block(7, 12, withTotal: true),
            ])
          : block(1, 12, withTotal: true),
    );
  }
}
