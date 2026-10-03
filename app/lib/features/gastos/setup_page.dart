import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';

/// Onboarding del módulo de gastos: solo lo imprescindible para empezar a apuntar.
class GastosSetupPage extends ConsumerStatefulWidget {
  const GastosSetupPage({super.key});

  @override
  ConsumerState<GastosSetupPage> createState() => _GastosSetupPageState();
}

class _GastosSetupPageState extends ConsumerState<GastosSetupPage> {
  final _bank = TextEditingController();
  final _balance = TextEditingController();
  final _payroll = TextEditingController();
  final _payday = TextEditingController(text: '27');
  bool _refugio = true;
  final _refBank = TextEditingController();
  final _refBalance = TextEditingController(text: '0');
  final _target = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_bank, _balance, _payroll, _payday, _refBank, _refBalance, _target]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _amt(TextEditingController c) {
    final v = parseEsDecimal(c.text);
    return v == null ? null : apiAmount(v);
  }

  Future<void> _save() async {
    final balance = _amt(_balance);
    final day = int.tryParse(_payday.text);
    if (_bank.text.trim().isEmpty || balance == null || day == null || day < 1 || day > 31) {
      setState(() => _error = 'Banco, saldo actual y día de cobro (1-31) son obligatorios');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).getGastosApi().setup(
            gastosSetupIn: GastosSetupIn(
              bank: _bank.text.trim(),
              currentBalance: balance,
              paydayDay: day,
              usualPayroll: _amt(_payroll),
              refugioBank: _refugio ? _refBank.text.trim() : null,
              refugioBalance: _refugio ? _amt(_refBalance) : null,
              emergencyTarget: _amt(_target),
            ),
          );
      ref.invalidate(gastosSettingsProvider);
      ref.invalidate(categoriesProvider);
      refreshGastos(ref);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AuthCard(children: [
      const Icon(Icons.receipt_long_outlined, size: 48),
      const SizedBox(height: 8),
      Text('Configura tus gastos', style: tt.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(
        'Fanal organiza tus gastos por ciclos de nómina: de un cobro al siguiente.',
        textAlign: TextAlign.center,
        style: tt.bodyMedium,
      ),
      const SizedBox(height: 20),
      FormSection(children: [
        FaroTextField(label: 'Banco donde cobras la nómina', controller: _bank),
        MoneyField(label: 'Saldo actual de esa cuenta', controller: _balance, allowNegative: true),
        FieldRow(children: [
          UnitsField(
            label: 'Día de cobro habitual',
            controller: _payday,
            integer: true,
            helper: 'Si cae en finde, el lunes',
          ),
          MoneyField(label: 'Nómina habitual', controller: _payroll, allowNegative: true),
        ]),
        SwitchField(
          title: 'Tengo un fondo de emergencia en otra cuenta',
          value: _refugio,
          onChanged: (v) => setState(() => _refugio = v),
        ),
        if (_refugio) ...[
          FaroTextField(label: 'Banco o app del fondo', controller: _refBank),
          FieldRow(children: [
            MoneyField(label: 'Saldo actual', controller: _refBalance, allowNegative: true),
            MoneyField(label: 'Objetivo', controller: _target, allowNegative: true),
          ]),
        ],
      ]),
      ErrorText(_error),
      const SizedBox(height: 20),
      FormActions(primaryLabel: 'Empezar', onPrimary: _save, busy: _busy, expand: true),
    ]);
  }
}
