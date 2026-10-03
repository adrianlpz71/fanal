import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/forms/forms.dart';
import '../../core/widgets.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _emailError, _passwordError;

  @override
  void initState() {
    super.initState();
    final s = ref.read(authProvider);
    if (s is AuthLoggedOut) _error = s.message;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = _email.text.contains('@') ? null : 'Introduce un email válido';
    final passwordError = _password.text.isEmpty ? 'Introduce la contraseña' : null;
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(authProvider.notifier).login(_email.text, _password.text);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(children: [
      const Center(child: FaroLogo(size: 48, withName: true)),
      const SizedBox(height: 8),
      Text('Tus finanzas, con rumbo.',
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 32),
      AutofillGroup(
        child: Column(spacing: FaroTheme.fieldGap, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FaroTextField(
            key: const Key('login-email'),
            label: 'Email',
            controller: _email,
            error: _emailError,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          FaroTextField(
            key: const Key('login-password'),
            label: 'Contraseña',
            controller: _password,
            error: _passwordError,
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Mostrar' : 'Ocultar',
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
          ),
        ]),
      ),
      ErrorText(_error, textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton(
        key: const Key('login-submit'),
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Entrar'),
      ),
    ]);
  }
}
