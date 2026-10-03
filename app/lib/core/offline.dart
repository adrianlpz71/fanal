import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/auth/auth_controller.dart' show sessionUserIdProvider;
import 'api.dart';

/// Sin conexión: se guarda el último ciclo visto (para consultarlo) y los gastos que se apuntan
/// sin red se ponen en cola y se envían solos al volver la conexión. Cada gasto lleva su UUID
/// desde el principio, así que reenviarlo nunca lo duplica (la API es idempotente por id).
/// Todo va por usuario: en un móvil compartido nadie ve la caché ni envía la cola de otro.
const _storage = FlutterSecureStorage();
String _queueKey(String user) => 'faro.offline.movements.$user';
String _cycleKey(String user) => 'faro.offline.cycle.$user';

bool isNetworkError(Object e) =>
    e is DioException &&
    e.response == null &&
    const {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.unknown,
    }.contains(e.type);

// --- Caché del ciclo actual ----------------------------------------------------------------------
class CachedCycle {
  const CachedCycle(this.cycle, this.savedAt);
  final CycleDetailOut cycle;
  final DateTime savedAt;
}

Future<void> saveCycleCache(String user, CycleDetailOut c) async {
  try {
    await _storage.write(
        key: _cycleKey(user), value: jsonEncode({'at': DateTime.now().toIso8601String(), 'cycle': c.toJson()}));
  } catch (_) {}
}

Future<CachedCycle?> loadCycleCache(String user) async {
  try {
    final raw = await _storage.read(key: _cycleKey(user));
    if (raw == null) return null;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return CachedCycle(CycleDetailOut.fromJson(m['cycle'] as Map<String, dynamic>), DateTime.parse(m['at'] as String));
  } catch (_) {
    return null;
  }
}

/// Al cerrar sesión se borra la caché del ciclo (la cola se conserva para cuando vuelva a entrar).
Future<void> clearCycleCache(String user) async {
  try {
    await _storage.delete(key: _cycleKey(user));
  } catch (_) {}
}

/// Si el ciclo mostrado viene de la caché (sin conexión), cuándo se guardó.
class OfflineSinceController extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void set(DateTime? v) => state = v;
}

final offlineSinceProvider = NotifierProvider<OfflineSinceController, DateTime?>(OfflineSinceController.new);

// --- Cola de gastos -----------------------------------------------------------------------------
class PendingMovementsController extends Notifier<List<MovementIn>> {
  Timer? _timer;
  String? _user;

  @override
  List<MovementIn> build() {
    // Una cola por usuario: al cambiar de sesión se carga la del nuevo (o ninguna)
    _user = ref.watch(sessionUserIdProvider);
    ref.onDispose(() => _timer?.cancel());
    _load();
    return const [];
  }

  Future<void> _load() async {
    final user = _user;
    if (user == null) return;
    try {
      final raw = await _storage.read(key: _queueKey(user));
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      state = [for (final m in list) MovementIn.fromJson(m)];
      _schedule();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final user = _user;
    if (user == null) return;
    try {
      await _storage.write(key: _queueKey(user), value: jsonEncode([for (final m in state) m.toJson()]));
    } catch (_) {}
  }

  Future<void> enqueue(MovementIn m) async {
    state = [...state, m];
    await _persist();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (state.isNotEmpty) _timer = Timer.periodic(const Duration(seconds: 45), (_) => flush());
  }

  /// Envía lo pendiente. Devuelve cuántos se enviaron; para al primer fallo de red.
  Future<int> flush() async {
    if (state.isEmpty || _user == null) return 0;
    final api = ref.read(apiProvider).getGastosApi();
    var sent = 0;
    for (final m in [...state]) {
      try {
        await api.createMovement(movementIn: m);
      } catch (e) {
        if (isNetworkError(e)) break;
        // La API lo rechaza (dato inválido): se descarta para no bloquear la cola
      }
      state = state.where((x) => x.id != m.id).toList();
      sent++;
    }
    await _persist();
    _schedule();
    return sent;
  }
}

final pendingMovementsProvider =
    NotifierProvider<PendingMovementsController, List<MovementIn>>(PendingMovementsController.new);
