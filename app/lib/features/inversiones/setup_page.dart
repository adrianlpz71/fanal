import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';

/// Primera vez en Inversiones: solo lo que hace falta para empezar. Los objetivos y las
/// posiciones se añaden después desde la propia pantalla.
class InvSetupPage extends ConsumerStatefulWidget {
  const InvSetupPage({super.key});

  @override
  ConsumerState<InvSetupPage> createState() => _InvSetupPageState();
}

/// Plataformas habituales en España y los decimales con que suelen dar las participaciones.
const _known = <String, (PlatformInKindEnum, int)>{
  'MyInvestor': (PlatformInKindEnum.broker, 4),
  'Trade Republic': (PlatformInKindEnum.broker, 6),
  'Indexa Capital': (PlatformInKindEnum.broker, 4),
  'DEGIRO': (PlatformInKindEnum.broker, 0),
  'Interactive Brokers': (PlatformInKindEnum.broker, 4),
  'Binance': (PlatformInKindEnum.exchange, 8),
  'Neverless': (PlatformInKindEnum.exchange, 8),
  'Bit2Me': (PlatformInKindEnum.exchange, 8),
};

class _InvSetupPageState extends ConsumerState<InvSetupPage> {
  final _picked = <String>{};
  final _other = TextEditingController();
  final _monthly = TextEditingController();
  final _minOp = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_other, _monthly, _minOp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(apiProvider).getInversionesApi();
    try {
      final existing = {for (final p in (await api.listPlatforms()).data ?? const <PlatformOut>[]) p.name};
      final names = {..._picked, ..._other.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty)};
      for (final n in names.where((n) => !existing.contains(n))) {
        final k = _known[n];
        await api.createPlatform(
          platformIn: PlatformIn(name: n, kind: k?.$1 ?? PlatformInKindEnum.broker, unitsDecimals: k?.$2 ?? 4),
        );
      }
      final monthly = parseEsDecimal(_monthly.text);
      final minOp = parseEsDecimal(_minOp.text);
      await api.putSettings(
        invSettingsIn: InvSettingsIn(
          monthlyContribution: monthly == null ? null : apiAmount(monthly),
          minOperation: minOp == null ? null : apiAmount(minOp),
        ),
      );
      refreshInv(ref);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Inversiones')),
      body: FormListView(
        children: [
          Text('Vamos a preparar tu cartera', style: tt.titleLarge),
          const Text(
            'Tres preguntas. Después podrás añadir tus fondos, criptos o acciones y '
            'definir qué peso quieres para cada uno.',
          ),
          Text('1. ¿Dónde inviertes?', style: tt.titleMedium),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final n in _known.keys)
                FilterChip(
                  label: Text(n),
                  selected: _picked.contains(n),
                  onSelected: (v) => setState(() => v ? _picked.add(n) : _picked.remove(n)),
                ),
            ],
          ),
          FaroTextField(label: 'Otras plataformas', helper: 'Separadas por comas', controller: _other),
          Text('2. ¿Cuánto sueles aportar al mes?', style: tt.titleMedium),
          MoneyField(
            label: 'Aportación mensual',
            controller: _monthly,
            helper: 'Opcional. Se usa como importe por defecto al repartir una aportación.',
          ),
          Text('3. ¿Hay un importe mínimo por orden?', style: tt.titleMedium),
          MoneyField(
            label: 'Mínimo por orden',
            controller: _minOp,
            helper: 'Opcional. Al repartir, no se proponen órdenes más pequeñas (su parte va al resto).',
          ),
          ErrorText(_error),
          FilledButton(onPressed: _busy ? null : _save, child: const Text('Empezar')),
          const NoAdviceNote(),
        ],
      ),
    );
  }
}
