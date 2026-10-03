import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart' show userApi;
import '../gastos/data.dart' show shortDate;
import '../inversiones/data.dart' show qty, NoAdviceNote;
import 'data.dart' show monthNames;

final taxReportProvider = FutureProvider.family<TaxReportOut, int>(
  (ref, year) async => (await userApi(ref).getAnalyticsApi().taxReport(year: year)).data!,
);

String incomeKindLabel(IncomeOutKindEnum k) => switch (k) {
      IncomeOutKindEnum.interesCuenta => 'Intereses de cuenta',
      IncomeOutKindEnum.dividendo => 'Dividendos',
      IncomeOutKindEnum.interes => 'Intereses',
      IncomeOutKindEnum.recompensaCripto => 'Recompensas de cripto',
    };

String _incomeKindNote(IncomeOutKindEnum k) => switch (k) {
      IncomeOutKindEnum.interesCuenta => 'Detectados por el concepto del movimiento',
      IncomeOutKindEnum.recompensaCripto => 'Valoradas al recibirlas; revisa su tratamiento',
      _ => '',
    };

/// Rendimientos agrupados por origen y tipo (p. ej. las recompensas semanales de un exchange):
/// una línea con el total y, dentro, el desglose por mes.
class IncomeGroup {
  IncomeGroup(this.source, this.kind);
  final String source;
  final IncomeOutKindEnum kind;
  final List<IncomeOut> items = [];

  Decimal get total => items.fold(Decimal.zero, (a, i) => a + dec(i.amount));
  DateTime get first => items.map((i) => i.date).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime get last => items.map((i) => i.date).reduce((a, b) => a.isAfter(b) ? a : b);

  /// (año, mes) → (nº de pagos, total), en orden.
  List<(int, int, int, Decimal)> get byMonth {
    final m = <(int, int), (int, Decimal)>{};
    for (final i in items) {
      final k = (i.date.year, i.date.month);
      final cur = m[k] ?? (0, Decimal.zero);
      m[k] = (cur.$1 + 1, cur.$2 + dec(i.amount));
    }
    final keys = m.keys.toList()..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [for (final k in keys) (k.$1, k.$2, m[k]!.$1, m[k]!.$2)];
  }
}

List<IncomeGroup> groupIncome(List<IncomeOut> income) {
  final out = <(String, IncomeOutKindEnum), IncomeGroup>{};
  for (final i in income) {
    out.putIfAbsent((i.source_, i.kind), () => IncomeGroup(i.source_, i.kind)).items.add(i);
  }
  return out.values.toList()..sort((a, b) => b.total.compareTo(a.total));
}

/// Informe fiscal del año: lo que hay que mirar al hacer la Renta (no la sustituye).
class TaxReportPage extends ConsumerStatefulWidget {
  const TaxReportPage({super.key});

  @override
  ConsumerState<TaxReportPage> createState() => _TaxReportPageState();
}

class _TaxReportPageState extends ConsumerState<TaxReportPage> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(taxReportProvider(_year));
    final tt = Theme.of(context).textTheme;
    // Un año cabe en poco: el selector no ocupa todo el ancho de la columna
    final year = Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: SelectField<int>(
          key: const Key('tax-year'),
          label: 'Año',
          value: _year,
          options: [
            for (var y = DateTime.now().year; y >= DateTime.now().year - 5; y--) SelectOption(y, '$y'),
          ],
          onChanged: (v) => setState(() => _year = v),
        ),
      ),
    );
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Informe fiscal')),
      body: r.when(
        loading: () => FormListView(children: [year, const Center(child: CircularProgressIndicator())]),
        error: (e, _) => FormListView(children: [year, Center(child: Text(apiErrorMessage(e)))]),
        data: (x) {
          final groups = groupIncome(x.income);
          return FormListView(children: [
            year,
            Card(
              child: ListTile(
                title: Text('Base del ahorro $_year (antes de compensar)'),
                subtitle: Text('Ganancias por ventas ${eur(x.gainsTotal, plus: true)} · rendimientos ${eur(x.incomeTotal)}'),
                trailing: Text(eur(x.savingsBase, plus: true), style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('to-tax-simulator'),
                icon: const Icon(Icons.calculate_outlined, size: 18),
                label: const Text('¿Cuánto pagarías? Simúlalo en Planes → Impuestos'),
                onPressed: () => context.go('/planes/impuestos'),
              ),
            ),
            SectionCard(title: 'Ventas', subtitle: 'Ganancia o pérdida según FIFO', children: [
              if (x.sales.isEmpty) const ListTile(dense: true, title: Text('Ninguna')),
              for (final s in x.sales)
                ListTile(
                  dense: true,
                  title: Text('${s.asset} · ${shortDate(s.date)}'),
                  subtitle: Text('${qty(s.units)}${nbsp}part. · transmisión ${eur(s.proceeds)} · adquisición ${eur(s.cost)}'),
                  trailing: MoneyText.api(s.gain, plus: true, colored: true, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
            ]),
            if (x.transfers.isNotEmpty)
              SectionCard(title: 'Traspasos entre fondos', subtitle: 'No tributan', children: [
                for (final t in x.transfers)
                  ListTile(dense: true, title: Text('${t.asset} · ${shortDate(t.date)}'), trailing: Text('${qty(t.units)}${nbsp}part.')),
              ]),
            SectionCard(title: 'Rendimientos', subtitle: 'Agrupados por origen; despliega para ver cada mes', children: [
              if (groups.isEmpty) const ListTile(dense: true, title: Text('Ninguno')),
              for (final g in groups)
                ExpansionTile(
                  key: Key('income-${g.source}-${g.kind.value}'),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text('${g.source} · ${incomeKindLabel(g.kind)}'),
                  subtitle: Text([
                    g.items.length == 1
                        ? '1 pago el ${shortDate(g.first)}'
                        : '${g.items.length} pagos del ${shortDate(g.first)} al ${shortDate(g.last)}',
                    if (_incomeKindNote(g.kind).isNotEmpty) _incomeKindNote(g.kind),
                  ].join(' · ')),
                  trailing: Text(eur(g.total.toString()), style: const TextStyle(fontWeight: FontWeight.w600)),
                  children: [
                    for (final (y, m, n, total) in g.byMonth)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(left: 32, right: 16),
                        title: Text('${monthNames[m - 1]} $y'),
                        subtitle: Text('$n ${n == 1 ? 'pago' : 'pagos'}'),
                        trailing: Text(eur(total.toString())),
                      ),
                  ],
                ),
            ]),
            // Con el año abierto, los saldos son los de hoy (el 31/12 todavía no ha llegado)
            SectionCard(
                title: _year >= DateTime.now().year ? 'Saldos y posiciones a hoy' : 'Saldos y posiciones a 31/12/$_year',
                children: [
              for (final y in x.yearEnd)
                ListTile(
                  dense: true,
                  leading: Icon(y.kind == YearEndOutKindEnum.cuenta ? Icons.account_balance_outlined : Icons.show_chart, size: 20),
                  title: Text(y.name),
                  subtitle: y.foreignHint ? const Text('En el extranjero') : null,
                  trailing: Text(eur(y.value)),
                ),
              if (dec(x.foreignTotal) > dec('50000'))
                const ListTile(
                  leading: Icon(Icons.warning_amber),
                  title: Text('Más de 50.000 € en el extranjero: revisa la obligación del modelo 720 / 721.'),
                ),
            ]),
            const NoAdviceNote(text: 'Resumen con tus datos de Fanal para preparar la Renta. No incluye compensaciones '
                'de años anteriores ni retenciones, y no sustituye a la declaración ni al borrador de la AEAT.'),
          ]);
        },
      ),
    );
  }
}
