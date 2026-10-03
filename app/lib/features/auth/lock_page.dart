import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets.dart';
import 'auth_controller.dart';

/// Android: pantalla de bloqueo. Pide la huella (o la credencial del dispositivo) nada más abrirse.
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(authProvider.notifier).unlock();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    final msg = s is AuthLocked ? s.message : null;
    return AuthCard(children: [
      const Center(child: FaroLogo(size: 56)),
      const SizedBox(height: 24),
      Text('Fanal está bloqueado',
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
      ErrorText(msg, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton.icon(
        icon: const Icon(Icons.fingerprint),
        label: const Text('Desbloquear'),
        onPressed: _busy ? null : _unlock,
      ),
      TextButton(
        onPressed: () => ref.read(authProvider.notifier).logout(),
        child: const Text('Cerrar sesión'),
      ),
    ]);
  }
}
