import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets.dart';
import 'auth_controller.dart';

class RecoveryCodesPage extends ConsumerStatefulWidget {
  const RecoveryCodesPage({super.key});

  @override
  ConsumerState<RecoveryCodesPage> createState() => _RecoveryCodesPageState();
}

class _RecoveryCodesPageState extends ConsumerState<RecoveryCodesPage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    if (s is! AuthRecoveryCodes) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;
    return AuthCard(children: [
      const Icon(Icons.verified_user_outlined, size: 48),
      const SizedBox(height: 12),
      Text('2FA activada', style: tt.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(
        'Guarda estos códigos en tu gestor de contraseñas. Cada uno sirve una vez si pierdes '
        'el móvil. No se volverán a mostrar.',
        textAlign: TextAlign.center,
        style: tt.bodyMedium,
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final c in s.codes)
                Text(c, style: tt.titleMedium?.copyWith(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        icon: const Icon(Icons.copy),
        label: const Text('Copiar todos'),
        onPressed: () => Clipboard.setData(ClipboardData(text: s.codes.join('\n'))),
      ),
      CheckboxListTile(
        value: _saved,
        onChanged: (v) => setState(() => _saved = v ?? false),
        title: const Text('Los he guardado en un sitio seguro'),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      FilledButton(
        onPressed: _saved ? () => ref.read(authProvider.notifier).acknowledgeRecoveryCodes() : null,
        child: const Text('Continuar'),
      ),
    ]);
  }
}
