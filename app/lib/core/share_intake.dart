import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fichero que otra app ha compartido con Faro (Android: "Compartir → Faro").
class SharedFile {
  const SharedFile({required this.path, required this.name, required this.mime});
  final String path;
  final String name;
  final String mime;

  static SharedFile? fromMap(Object? m) {
    if (m is! Map) return null;
    final path = m['path'] as String?;
    if (path == null || path.isEmpty) return null;
    return SharedFile(path: path, name: (m['name'] as String?) ?? 'fichero', mime: (m['mime'] as String?) ?? '');
  }
}

class SharedFileNotifier extends Notifier<SharedFile?> {
  @override
  SharedFile? build() => null;

  void set(SharedFile? f) => state = f;
  void clear() => state = null;
}

final sharedFileProvider = NotifierProvider<SharedFileNotifier, SharedFile?>(SharedFileNotifier.new);

const _channel = MethodChannel('faro/share');

/// Escucha los ficheros compartidos (solo Android). El que abrió la app se recoge al arrancar.
Future<void> initShareIntake(WidgetRef ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'fileShared') ref.read(sharedFileProvider.notifier).set(SharedFile.fromMap(call.arguments));
  });
  try {
    final first = SharedFile.fromMap(await _channel.invokeMethod<Object?>('initialFile'));
    if (first != null) ref.read(sharedFileProvider.notifier).set(first);
  } on PlatformException {
    // sin fichero compartido
  }
}
