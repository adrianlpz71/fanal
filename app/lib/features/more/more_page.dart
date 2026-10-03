import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/forms/forms.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api.dart';
import '../../core/env.dart';
import '../../core/notifications.dart';
import '../../core/privacy.dart';
import '../../core/regions.dart';
import '../auth/auth_controller.dart';
import '../update/update_banner.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Tema: oscuro por defecto. Lo que elijas se recuerda en el dispositivo.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'faro.theme';
  final _storage = const FlutterSecureStorage();

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark;
  }

  Future<void> _load() async {
    try {
      final stored = await _storage.read(key: _key);
      final v = ThemeMode.values.where((m) => m.name == stored).firstOrNull;
      if (v != null && v != state) state = v;
    } catch (_) {
      // sin almacenamiento seguro (tests): oscuro
    }
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    try {
      await _storage.write(key: _key, value: m.name);
    } catch (_) {}
  }

  /// Botón de la barra: pasa de claro a oscuro y al revés (desde "Sistema", al contrario del actual).
  void toggle(Brightness current) => set(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final version = ref.watch(appVersionProvider).value;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Tú')),
      body: ListView(children: [
        if (user != null)
          ListTile(
            key: const Key('profile-edit'),
            leading: CircleAvatar(
              child: Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?'),
            ),
            title: Text(user.displayName.isNotEmpty ? user.displayName : user.email),
            subtitle: Text('${user.email} · ${taxRegions[user.taxRegion] ?? user.taxRegion}'),
            trailing: const Icon(Icons.edit_outlined, semanticLabel: 'Editar perfil'),
            onTap: () => showFormPanel<void>(context, builder: (_) => _ProfileForm(user: user)),
          ),
        const Divider(),
        const SectionHeader('Apariencia'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedField<ThemeMode>(
            segments: const [
              Segment(ThemeMode.system, 'Sistema', icon: Icons.brightness_auto),
              Segment(ThemeMode.light, 'Claro', icon: Icons.light_mode_outlined),
              Segment(ThemeMode.dark, 'Oscuro', icon: Icons.dark_mode_outlined),
            ],
            value: mode,
            onChanged: (v) => ref.read(themeModeProvider.notifier).set(v),
          ),
        ),
        SwitchListTile(
          key: const Key('privacy-switch'),
          secondary: const Icon(Icons.visibility_off_outlined),
          title: const Text('Modo privacidad'),
          subtitle: const Text('Oculta los importes en toda la app (para enseñarla)'),
          value: ref.watch(privacyProvider),
          onChanged: (v) => ref.read(privacyProvider.notifier).set(v),
        ),
        if (Notifications.supported)
          SwitchListTile(
            key: const Key('notifications-switch'),
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Avisos'),
            subtitle: const Text('Víspera del cobro, cargos y cuotas del día, aportaciones y cartera fuera de rango'),
            value: ref.watch(notificationsProvider),
            onChanged: (v) => ref.read(notificationsProvider.notifier).set(v),
          ),
        const Divider(),
        const SectionHeader('Tus datos'),
        ListTile(
          leading: const Icon(Icons.table_view_outlined),
          title: const Text('Exportar a Excel'),
          subtitle: const Text('Todo lo que tienes en Fanal, una hoja por tabla'),
          onTap: () => exportData(context, ref, 'xlsx'),
        ),
        ListTile(
          leading: const Icon(Icons.data_object),
          title: const Text('Exportar copia completa (JSON)'),
          subtitle: const Text('Para guardarla o llevártela a otra herramienta'),
          onTap: () => exportData(context, ref, 'json'),
        ),
        const Divider(),
        const SectionHeader('Aplicación'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text('Fanal ${version?.current ?? ''}'),
          subtitle: Text(
            version?.server == null
                ? 'Sin conexión con el servidor'
                : 'API ${version!.server!.apiVersion}'
                    '${version.latest != null ? ' · última app ${version.latest!.version}' : ''}',
          ),
        ),
        if (kIsWeb)
          ListTile(
            leading: const Icon(Icons.android),
            title: const Text('Descargar la app Android'),
            onTap: () => launchUrl(Uri.parse('${Env.apiOrigin}/descargar/')),
          ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
          title: const Text('Cerrar sesión'),
          onTap: () => confirmLogout(context, ref),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Fanal muestra cálculos y supuestos; no es asesoramiento financiero ni fiscal.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

/// Perfil: nombre y residencia fiscal (`PATCH /me`). El correo no se cambia desde aquí.
class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});
  final UserOut user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _name = TextEditingController(text: widget.user.displayName);
  late String _region = taxRegions.containsKey(widget.user.taxRegion) ? widget.user.taxRegion : 'ES-CN';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return setState(() => _error = 'Pon un nombre');
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getMeApi().updateProfile(
            profileIn: ProfileIn(displayName: _name.text.trim(), taxRegion: _region),
          );
      ref.read(authProvider.notifier).updateUser(r.data!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FormPanel(
        title: 'Tu perfil',
        onSubmit: _busy ? null : _save,
        actions: FormActions(
          primaryKey: const Key('save-profile'),
          primaryLabel: 'Guardar',
          busy: _busy,
          expand: context.isCompact,
          onPrimary: _save,
        ),
        children: [
          FaroTextField(
            key: const Key('profile-name'),
            label: 'Nombre',
            controller: _name,
            textCapitalization: TextCapitalization.words,
          ),
          SelectField<String>(
            key: const Key('profile-region'),
            label: 'Residencia fiscal',
            helper: 'Define los tramos autonómicos de IRPF y Patrimonio',
            value: _region,
            options: [for (final e in taxRegions.entries) SelectOption(e.key, e.value)],
            onChanged: (v) => setState(() => _region = v),
          ),
          if (_error != null) ErrorText(_error),
        ],
      );
}

/// Descarga la exportación y la guarda donde elijas (en la web, se descarga).
Future<void> exportData(BuildContext context, WidgetRef ref, String format) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Preparando la exportación…')));
  try {
    final r = await ref.read(dioProvider).get<List<int>>('/api/export',
        queryParameters: {'format': format}, options: Options(responseType: ResponseType.bytes));
    final now = DateTime.now();
    final name = 'faro-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.$format';
    await FilePicker.saveFile(
      fileName: name,
      bytes: Uint8List.fromList(r.data!),
      mimeType: format == 'json'
          ? 'application/json'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
  }
}

/// Cerrar sesión, con confirmación (se borran la caché y los avisos de este dispositivo).
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await confirmDialog(
    context,
    title: '¿Cerrar sesión?',
    message: 'Se borran de este dispositivo los datos guardados para usar Fanal sin conexión y los avisos.',
    confirmLabel: 'Cerrar sesión',
    destructive: false,
  );
  if (ok) await ref.read(authProvider.notifier).logout();
}
