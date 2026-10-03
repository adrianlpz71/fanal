import 'package:flutter/material.dart';

/// Confirmación de una acción destructiva. Mismo texto y el mismo botón en toda la app.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Eliminar',
  bool destructive = true,
}) async {
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(
          key: const Key('confirm-ok'),
          style: destructive ? FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError) : null,
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Aviso abajo con "Deshacer" para lo que se puede revertir.
void showUndoSnack(BuildContext context, String message, {required VoidCallback onUndo}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 6),
    action: SnackBarAction(label: 'Deshacer', onPressed: onUndo),
  ));
}
