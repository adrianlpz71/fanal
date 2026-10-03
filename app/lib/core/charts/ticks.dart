import 'dart:math' as math;

import '../dates.dart';
import '../money.dart';

/// Escala de un eje con valores "redondos" (1 · 2 · 2,5 · 5 × 10ⁿ): las etiquetas no se pisan y
/// el mínimo y el máximo caen en una marca.
class AxisScale {
  const AxisScale(this.min, this.max, this.interval);
  final double min, max, interval;

  List<double> get ticks {
    final out = <double>[];
    for (var v = min; v <= max + interval * 1e-6; v += interval) {
      out.add(v);
    }
    return out;
  }

  /// ¿`v` es una de las marcas? (fl_chart pide etiquetas también en valores intermedios).
  bool isTick(double v) {
    final k = (v - min) / interval;
    return (k - k.roundToDouble()).abs() < 1e-6;
  }
}

double _nice(double raw) {
  if (raw <= 0 || raw.isNaN || raw.isInfinite) return 1;
  final exp = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final f = raw / exp;
  final n = f <= 1
      ? 1.0
      : f <= 2
          ? 2.0
          : f <= 2.5
              ? 2.5
              : f <= 5
                  ? 5.0
                  : 10.0;
  return n * exp;
}

AxisScale niceScale(double lo, double hi, {int ticks = 5, bool includeZero = false}) {
  if (includeZero) {
    lo = math.min(lo, 0);
    hi = math.max(hi, 0);
  }
  if (lo == hi) {
    final pad = lo == 0 ? 1.0 : lo.abs() * 0.1;
    lo -= pad;
    hi += pad;
  }
  final step = _nice((hi - lo) / math.max(1, ticks - 1));
  final min = (lo / step).floor() * step;
  final max = (hi / step).ceil() * step;
  return AxisScale(min, max, step);
}

String _es(double v, int decimals) => v.toStringAsFixed(decimals).replaceAll('.', ',');

/// Importe compacto para ejes: "850 €", "1,2k €", "15k €", "1,4M €". Con el modo privacidad, "•••".
String compactEur(double v) {
  if (privacyMode) return '•••';
  final a = v.abs();
  final sign = v < 0 ? minus : '';
  if (a >= 1e6) return '$sign${_es(a / 1e6, a >= 1e7 ? 0 : 1).replaceAll(',0', '')}M$nbsp€';
  if (a >= 1e3) return '$sign${_es(a / 1e3, a >= 1e4 ? 0 : 1).replaceAll(',0', '')}k$nbsp€';
  return '$sign${a.round()}$nbsp€';
}

/// Porcentaje compacto para ejes ("12 %", "−3,5 %"). `v` en tanto por cien.
String compactPct(double v) {
  final s = (v - v.roundToDouble()).abs() < 1e-9 ? v.round().toString() : _es(v, 1);
  return '${withMinus(s)} %';
}

/// Unidad del eje de fechas según el periodo y el ancho disponible.
enum DateStep { day, week, month, quarter, year }

/// Marcas del eje X de fechas: únicas (nunca "sep 26, sep 26") y espaciadas para que quepan.
class DateTicks {
  DateTicks(this.ticks, this.step);
  final List<DateTime> ticks;
  final DateStep step;

  String label(DateTime d) => switch (step) {
        DateStep.day || DateStep.week => dayMonth(d),
        DateStep.month || DateStep.quarter => monthYear(d),
        DateStep.year => '${d.year}',
      };
}

DateTicks dateTicks(DateTime from, DateTime to, double width, {double labelWidth = 64}) {
  final days = to.difference(from).inDays.abs().clamp(1, 100000);
  final maxLabels = math.max(2, (width / labelWidth).floor());
  DateStep step;
  if (days / 1 <= maxLabels) {
    step = DateStep.day;
  } else if (days / 7 <= maxLabels) {
    step = DateStep.week;
  } else if (days / 30.4 <= maxLabels) {
    step = DateStep.month;
  } else if (days / 91.3 <= maxLabels) {
    step = DateStep.quarter;
  } else {
    step = DateStep.year;
  }
  final out = <DateTime>[];
  DateTime d;
  switch (step) {
    case DateStep.day:
      d = DateTime(from.year, from.month, from.day);
      while (!d.isAfter(to)) {
        out.add(d);
        d = DateTime(d.year, d.month, d.day + 1);
      }
    case DateStep.week:
      d = DateTime(from.year, from.month, from.day);
      d = d.add(Duration(days: (8 - d.weekday) % 7)); // lunes
      while (!d.isAfter(to)) {
        out.add(d);
        d = DateTime(d.year, d.month, d.day + 7);
      }
    case DateStep.month || DateStep.quarter:
      final inc = step == DateStep.month ? 1 : 3;
      var m = from.month;
      if (step == DateStep.quarter) m = ((m - 1) ~/ 3) * 3 + 1;
      d = DateTime(from.year, m, 1);
      if (d.isBefore(DateTime(from.year, from.month, from.day))) d = DateTime(d.year, d.month + inc, 1);
      while (!d.isAfter(to)) {
        out.add(d);
        d = DateTime(d.year, d.month + inc, 1);
      }
    case DateStep.year:
      d = DateTime(from.year, 1, 1);
      if (d.isBefore(DateTime(from.year, from.month, from.day))) d = DateTime(d.year + 1, 1, 1);
      while (!d.isAfter(to)) {
        out.add(d);
        d = DateTime(d.year + 1, 1, 1);
      }
  }
  // Si aun así no caben (periodos muy largos), una de cada N
  if (out.length > maxLabels) {
    final every = (out.length / maxLabels).ceil();
    final thinned = [for (var i = 0; i < out.length; i += every) out[i]];
    return DateTicks(thinned, step);
  }
  return DateTicks(out, step);
}

/// Días desde la época (eje X de las gráficas de fechas).
double dayNumber(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch / 86400000;
DateTime dayFromNumber(double x) =>
    DateTime.fromMillisecondsSinceEpoch((x * 86400000).round(), isUtc: true);

/// Periodos del selector de las gráficas.
enum ChartPeriod { m1, m3, m6, ytd, y1, all }

const chartPeriodLabels = {
  ChartPeriod.m1: '1M',
  ChartPeriod.m3: '3M',
  ChartPeriod.m6: '6M',
  ChartPeriod.ytd: 'YTD',
  ChartPeriod.y1: '1A',
  ChartPeriod.all: 'Todo',
};

/// Primer día del periodo (o `null` para "Todo").
DateTime? periodStart(ChartPeriod p, DateTime now) => switch (p) {
      ChartPeriod.m1 => DateTime(now.year, now.month - 1, now.day),
      ChartPeriod.m3 => DateTime(now.year, now.month - 3, now.day),
      ChartPeriod.m6 => DateTime(now.year, now.month - 6, now.day),
      ChartPeriod.ytd => DateTime(now.year, 1, 1),
      ChartPeriod.y1 => DateTime(now.year - 1, now.month, now.day),
      ChartPeriod.all => null,
    };
