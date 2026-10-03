import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/regions.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart';

/// Onboarding inicial (perfil). Solo lo imprescindible; cada módulo hará sus propias preguntas
/// la primera vez que se abra (cuenta y nómina en gastos, plataformas en inversiones, objetivos
/// FIRE en planes…).
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _name = TextEditingController();
  DateTime? _birth;
  String _region = 'ES-CN';
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = ref.read(authProvider);
    if (s is AuthAuthenticated) {
      _name.text = s.user.displayName;
      _birth = s.user.birthDate;
      _region = taxRegions.containsKey(s.user.taxRegion) ? s.user.taxRegion : 'ES-CN';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 16),
      initialEntryMode: DatePickerEntryMode.input,
      helpText: 'Fecha de nacimiento',
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _save() async {
    if (_birth == null) {
      setState(() => _error = 'Necesito tu fecha de nacimiento para los cálculos de jubilación');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final b = _birth!;
      final r = await ref.read(apiProvider).getMeApi().updateProfile(
            profileIn: ProfileIn(
              displayName: _name.text.trim(),
              birthDate: DateTime.utc(b.year, b.month, b.day),
              taxRegion: _region,
              completeOnboarding: true,
            ),
          );
      ref.read(authProvider.notifier).updateUser(r.data!);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM y', 'es_ES');
    return AuthCard(children: [
      const Center(child: FaroLogo(size: 40)),
      const SizedBox(height: 16),
      Text('Bienvenido a Fanal', textAlign: TextAlign.center, style: tt.titleLarge),
      const SizedBox(height: 8),
      Text(
        'Tres datos para empezar. Lo demás te lo preguntaré cuando abras cada sección.',
        textAlign: TextAlign.center,
        style: tt.bodyMedium,
      ),
      const SizedBox(height: 24),
      Column(spacing: FaroTheme.fieldGap, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FaroTextField(
          label: '¿Cómo te llamo?',
          controller: _name,
          textCapitalization: TextCapitalization.words,
        ),
        InkWell(
          onTap: _pickBirth,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de nacimiento',
              helperText: 'Para calcular tu edad de independencia financiera',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(_birth == null ? 'Elegir…' : fmt.format(_birth!)),
          ),
        ),
        SelectField<String>(
          label: 'Residencia fiscal',
          helper: 'Define los tramos autonómicos de IRPF y Patrimonio',
          value: _region,
          options: [for (final e in taxRegions.entries) SelectOption(e.key, e.value)],
          onChanged: (v) => setState(() => _region = v),
        ),
      ]),
      ErrorText(_error),
      const SizedBox(height: 24),
      FilledButton(onPressed: _busy ? null : _save, child: const Text('Empezar')),
    ]);
  }
}
