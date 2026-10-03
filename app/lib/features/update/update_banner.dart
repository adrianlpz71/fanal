import 'package:faro_api/faro_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api.dart';
import '../../core/env.dart';

class AppVersionInfo {
  const AppVersionInfo({required this.current, required this.currentBuild, this.server});
  final String current;
  final int currentBuild;
  final VersionOut? server;

  AppRelease? get latest => server?.app;
  bool get updateAvailable => !kIsWeb && latest != null && latest!.build > currentBuild;
  bool get updateRequired => !kIsWeb && latest != null && (latest!.minSupportedBuild ?? 0) > currentBuild;

  Uri? get apkUri => latest == null ? null : Uri.parse(Env.apiOrigin).resolve(latest!.apkUrl);
}

final appVersionProvider = FutureProvider<AppVersionInfo>((ref) async {
  final pkg = await PackageInfo.fromPlatform();
  VersionOut? server;
  try {
    server = (await ref.read(apiProvider).getSystemApi().version()).data;
  } catch (_) {
    server = null;
  }
  return AppVersionInfo(
    current: pkg.version,
    currentBuild: int.tryParse(pkg.buildNumber) ?? 0,
    server: server,
  );
});

/// Aviso de nueva versión del APK (solo Android; la web siempre está al día).
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(appVersionProvider).value;
    if (info == null || !info.updateAvailable) return const SizedBox.shrink();
    return MaterialBanner(
      leading: const Icon(Icons.system_update),
      content: Text(info.updateRequired
          ? 'Esta versión ya no es compatible. Actualiza a la ${info.latest!.version}.'
          : 'Hay una versión nueva de Fanal (${info.latest!.version}).'),
      actions: [
        TextButton(
          onPressed: () => launchUrl(info.apkUri!, mode: LaunchMode.externalApplication),
          child: const Text('Descargar'),
        ),
      ],
    );
  }
}
