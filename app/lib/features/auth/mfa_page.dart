import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/forms/forms.dart';
import '../../core/widgets.dart';
import 'auth_controller.dart';

/// Verificación en dos pasos: alta (QR + secreto) la primera vez, o código TOTP / de recuperación.
class MfaPage extends ConsumerStatefulWidget {
  const MfaPage({super.key});

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _code = TextEditingController();
  bool _busy = false;
  bool _useRecovery = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.text.trim().length < 6) {
      setState(() => _error = 'Introduce el código');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(authProvider.notifier).submitCode(_code.text);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    if (s is! AuthMfa) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;

    return AuthCard(children: [
      const Center(child: FaroLogo(size: 40)),
      const SizedBox(height: 16),
      Text(s.setup ? 'Activa la verificación en dos pasos' : 'Verificación en dos pasos',
          textAlign: TextAlign.center, style: tt.titleLarge),
      const SizedBox(height: 12),
      if (s.setup) ...[
        Text(
          'Escanea el código con tu app de autenticación (Google Authenticator, Aegis, '
          '1Password…) e introduce el código de 6 dígitos.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (s.otpauthUri != null)
          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: QrImageView(data: s.otpauthUri!, size: 200),
            ),
          )
        else
          const Center(child: CircularProgressIndicator()),
        if (s.secret != null) ...[
          const SizedBox(height: 12),
          Text('¿No puedes escanear? Introduce esta clave:', style: tt.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: SelectableText(s.secret!,
                  key: const Key('mfa-secret'),
                  style: tt.bodyMedium?.copyWith(fontFamily: 'monospace', letterSpacing: 1.2)),
            ),
            IconButton(
              tooltip: 'Copiar',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => Clipboard.setData(ClipboardData(text: s.secret!)),
            ),
          ]),
        ],
      ] else
        Text(
          _useRecovery
              ? 'Introduce uno de tus códigos de recuperación (xxxx-xxxx).'
              : 'Introduce el código de 6 dígitos de tu app de autenticación.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium,
        ),
      const SizedBox(height: 20),
      FaroTextField(
        key: const Key('mfa-code'),
        label: _useRecovery ? 'Código de recuperación' : 'Código',
        hint: _useRecovery ? 'abcd-2345' : '000000',
        controller: _code,
        autofocus: true,
        textAlign: TextAlign.center,
        style: tt.headlineSmall?.copyWith(letterSpacing: 6),
        keyboardType: _useRecovery ? TextInputType.text : TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: _useRecovery
            ? [LengthLimitingTextInputFormatter(9)]
            : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        onSubmitted: (_) => _submit(),
      ),
      ErrorText(_error, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      FilledButton(
        key: const Key('mfa-submit'),
        onPressed: _busy ? null : _submit,
        child: Text(s.setup ? 'Activar' : 'Verificar'),
      ),
      const SizedBox(height: 8),
      if (!s.setup)
        TextButton(
          onPressed: () => setState(() {
            _useRecovery = !_useRecovery;
            _code.clear();
          }),
          child: Text(_useRecovery ? 'Usar código de la app' : 'Usar un código de recuperación'),
        ),
      TextButton(
        onPressed: () => ref.read(authProvider.notifier).cancelMfa(),
        child: const Text('Volver'),
      ),
    ]);
  }
}
