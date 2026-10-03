import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/dates.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show showSnack;
import 'data.dart';

/// Pide precios nuevos a las fuentes (lo que antes era "Actualizar precios ahora" del menú).
Future<void> refreshPrices(BuildContext context, WidgetRef ref) async {
  showSnack(context, 'Consultando precios…');
  try {
    final r = (await ref.read(apiProvider).getInversionesApi().refreshPrices()).data!;
    refreshInv(ref);
    final failed = r.where((x) => !x.ok).toList();
    if (!context.mounted) return;
    if (failed.isEmpty) {
      showSnack(context, '${r.length} precios actualizados');
    } else {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('${failed.length} sin precio nuevo'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final f in failed) Text('• ${f.assetName}: ${f.errors.join('; ')}'),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Vale'))],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

/// "Precios a 2 oct ⟳" en la barra de Inversiones y Patrimonio: fecha del precio más reciente y
/// botón para pedir precios nuevos. En aviso si hay precios desactualizados.
class PricesStatus extends ConsumerWidget {
  const PricesStatus({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configured = ref.watch(invSettingsProvider).value?.configured ?? false;
    final p = configured ? ref.watch(portfolioProvider).value : null;
    if (p == null) return const SizedBox.shrink();
    DateTime? latest;
    for (final c in p.classes) {
      for (final x in c.positions) {
        final d = x.priceDate;
        if (d != null && (latest == null || d.isAfter(latest))) latest = d;
      }
    }
    final stale = p.stale;
    final label = stale > 0
        ? '$stale ${stale == 1 ? 'precio' : 'precios'} sin actualizar'
        : latest == null
            ? 'Sin precios todavía'
            : 'Precios a ${dayMonth(latest)}';
    final color = stale > 0 ? context.faro.warning : null;
    if (compact) {
      return IconButton(
        key: const Key('prices-refresh'),
        tooltip: '$label · Actualizar precios',
        icon: Icon(stale > 0 ? Icons.update : Icons.sync, color: color),
        onPressed: () => refreshPrices(context, ref),
      );
    }
    return TextButton.icon(
      key: const Key('prices-refresh'),
      style: TextButton.styleFrom(foregroundColor: color),
      icon: Icon(stale > 0 ? Icons.update : Icons.sync, size: 18),
      label: Text(label),
      onPressed: () => refreshPrices(context, ref),
    );
  }
}
