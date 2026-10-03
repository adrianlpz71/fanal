import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';

/// "He cobrado": saldo real ANTES de la nómina (cierra el ciclo y registra el descuadre),
/// nómina y fecha, y qué hacer con los pendientes sin cargar.
Future<void> showPaydayDialog(BuildContext context, WidgetRef ref, CycleDetailOut cycle) async {
  final settings = await ref.read(gastosSettingsProvider.future);
  if (!context.mounted) return;
  final out = await showFormPanel<PaydayOut>(
    context,
    builder: (_) => _PaydayDialog(cycle: cycle, usualPayroll: settings.usualPayroll),
  );
  if (out == null || !context.mounted) return;
  final diff = dec(out.discrepancy);
  showUndoSnack(
    context,
    'Nuevo ciclo: ${out.opened.label} · saldo inicial ${eur(out.opened.summary.opening)}'
    '${diff.sign != 0 ? ' · descuadre ${formatEur(diff, showPlus: true)}' : ''}',
    onUndo: () => undoPayday(context, ref, confirm: false),
  );
}

/// Deshace el último "He cobrado": reabre el ciclo anterior y borra el nuevo con su nómina y el
/// ajuste de cuadre. Lo apuntado en el ciclo nuevo pasa al reabierto.
Future<void> undoPayday(BuildContext context, WidgetRef ref, {bool confirm = true}) async {
  if (confirm) {
    final ok = await confirmDialog(
      context,
      title: '¿Deshacer «He cobrado»?',
      message: 'Se reabre el ciclo anterior y se borra el nuevo, con su nómina y el ajuste de cuadre. '
          'Los pendientes vuelven a como estaban y lo que hayas apuntado en el ciclo nuevo pasa al reabierto.',
      confirmLabel: 'Deshacer',
    );
    if (!ok || !context.mounted) return;
  }
  try {
    final r = await ref.read(apiProvider).getGastosApi().undoPayday();
    refreshGastos(ref);
    ref.invalidate(gastosSettingsProvider);
    if (context.mounted) showSnack(context, 'Cobro deshecho: vuelves al ciclo ${r.data!.label}');
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

class _PaydayDialog extends ConsumerStatefulWidget {
  const _PaydayDialog({required this.cycle, this.usualPayroll});
  final CycleDetailOut cycle;
  final String? usualPayroll;

  @override
  ConsumerState<_PaydayDialog> createState() => _PaydayDialogState();
}

class _PaydayDialogState extends ConsumerState<_PaydayDialog> {
  late final _real = TextEditingController(
      text: dec(widget.cycle.summary.availableNow).toStringAsFixed(2).replaceAll('.', ','));
  late final _payroll = TextEditingController(
      text: widget.usualPayroll == null ? '' : dec(widget.usualPayroll).toStringAsFixed(2).replaceAll('.', ','));
  DateTime _date = DateTime.now();
  final Map<String, bool> _carry = {};
  bool _busy = false;
  String? _error;

  List<MovementOut> get _pending =>
      widget.cycle.movements.where((m) => m.status == MovementOutStatusEnum.planned).toList();

  @override
  void dispose() {
    _real.dispose();
    _payroll.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final real = parseEsDecimal(_real.text);
    final payroll = parseEsDecimal(_payroll.text);
    if (real == null || payroll == null) {
      setState(() => _error = 'Revisa los importes');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getGastosApi().payday(
            paydayIn: PaydayIn(
              payrollAmount: apiAmount(payroll),
              payrollDate: DateTime.utc(_date.year, _date.month, _date.day),
              realBalanceBefore: apiAmount(real),
              pendingActions: {
                for (final m in _pending)
                  m.id: (_carry[m.id] ?? true)
                      ? PaydayInPendingActionsEnum.carry
                      : PaydayInPendingActionsEnum.cancel,
              },
            ),
          );
      refreshGastos(ref);
      ref.invalidate(gastosSettingsProvider);
      if (!mounted) return;
      Navigator.pop(context, r.data!); // el aviso con "Deshacer" lo pone quien abrió el diálogo
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final computed = dec(widget.cycle.summary.availableNow);
    final real = parseEsDecimal(_real.text);
    final diff = real == null ? null : real - computed;
    return FormPanel(
      title: 'He cobrado',
      onSubmit: _busy ? null : _submit,
      actions: FormActions(
        primaryLabel: 'Cerrar ciclo y abrir el nuevo',
        onPrimary: _submit,
        busy: _busy,
        expand: context.isCompact,
      ),
      children: [
        FormSection(title: '1 · Saldo real del banco ANTES de la nómina', children: [
          MoneyField(
            label: 'Saldo real',
            controller: _real,
            allowNegative: true,
            helper: 'Calculado: ${formatEur(computed)}'
                '${diff != null && diff.sign != 0 ? ' · descuadre ${formatEur(diff, showPlus: true)}' : ''}',
            onChanged: (_) => setState(() {}),
          ),
        ]),
        FormSection(title: '2 · Nómina', children: [
          FieldRow(minWidth: 160, children: [
            MoneyField(label: 'Importe', controller: _payroll),
            DateField(
              label: 'Fecha de cobro',
              value: _date,
              first: DateTime(2020),
              last: DateTime(2100),
              onChanged: (d) {
                if (d != null) setState(() => _date = d);
              },
            ),
          ]),
        ]),
        if (_pending.isNotEmpty)
          FormSection(
            title: '3 · Pendientes sin cargar (${_pending.length})',
            subtitle: 'Activado = pasa al nuevo ciclo · desactivado = se cancela',
            children: [
              for (final m in _pending)
                SwitchField(
                  title: m.concept,
                  subtitle: eur(m.amount, plus: true),
                  value: _carry[m.id] ?? true,
                  onChanged: (v) => setState(() => _carry[m.id] = v),
                ),
            ],
          ),
        if (_error != null) ErrorText(_error),
      ],
    );
  }
}

/// Primer ciclo sin Excel (o tras quedarse sin ciclo abierto).
Future<void> showStartCycleDialog(BuildContext context, WidgetRef ref) async {
  final ctrl = TextEditingController();
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => FormPanel(
      title: 'Empezar ciclo',
      onSubmit: () => Navigator.pop(c, true),
      actions: FormActions(primaryLabel: 'Empezar', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
      children: [
        MoneyField(label: 'Saldo actual de la cuenta', controller: ctrl, autofocus: true, allowNegative: true),
      ],
    ),
  );
  final v = parseEsDecimal(ctrl.text);
  if (ok != true || v == null) return;
  try {
    await ref.read(apiProvider).getGastosApi().startCycle(cycleStartIn: CycleStartIn(currentBalance: apiAmount(v)));
    refreshGastos(ref);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
}
