import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/share_intake.dart';
import '../../core/widgets.dart';
import '../imports/import_wizard.dart';

/// Un fichero compartido con Faro: el asistente de importación pregunta de dónde es y lo importa.
class SharedFilePage extends ConsumerWidget {
  const SharedFilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(sharedFileProvider);
    if (f == null) {
      return Scaffold(
        appBar: const FaroAppBar(title: PageTitle('Fichero recibido')),
        body: Center(
          child: TextButton(onPressed: () => context.go('/gastos'), child: const Text('Nada que importar · volver')),
        ),
      );
    }
    return const ImportWizardPage();
  }
}
