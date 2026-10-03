import 'package:faro_api/faro_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'money.dart';

/// Avisos locales en Android (los programa el propio móvil con los datos que ya tiene Faro; no
/// hay servidor de notificaciones):
///   · víspera del cobro · cargos y cuotas previstos del día · aportaciones periódicas
///   · cartera fuera de rango (una vez por cambio) · resumen al empezar un ciclo nuevo
///   · revisión trimestral al empezar cada trimestre
/// Se reprograman todos cada vez que se abre la app o se actualiza el ciclo. Cada aviso lleva la
/// ruta de su pantalla: al tocarlo, la app se abre ahí (ver [AvisoRoute]).
class Notifications {
  Notifications._();
  static final instance = Notifications._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Ruta del aviso que se ha tocado, hasta que la app navega a ella (en cuanto hay sesión).
  final tapped = ValueNotifier<String?>(null);
  final _storage = const FlutterSecureStorage();
  bool _ready = false;

  static bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static const _channel = AndroidNotificationDetails(
    'faro_avisos',
    'Avisos de Fanal',
    channelDescription: 'Cobro, cargos previstos, cuotas, aportaciones y cartera',
    importance: Importance.defaultImportance,
  );

  Future<void> _init() async {
    if (_ready || !supported) return;
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Atlantic/Canary'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) => tapped.value = r.payload,
    );
    _ready = true;
  }

  /// Al arrancar: si la app se abrió tocando un aviso, su ruta queda en [tapped]; los toques con
  /// la app ya abierta llegan por `onDidReceiveNotificationResponse`.
  Future<void> listenTaps() async {
    if (!supported) return;
    try {
      await _init();
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) tapped.value = launch!.notificationResponse?.payload;
    } catch (_) {}
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Activados = el usuario no los apagó en Faro **y** Android tiene el permiso concedido (si
  /// se quitó desde los ajustes del sistema, el interruptor de Más sale apagado).
  Future<bool> enabled() async {
    if (!supported) return false;
    try {
      final stored = await _storage.read(key: 'faro.notifications');
      if (!avisosOn(stored)) return false;
      await _init();
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// La primera vez que hay sesión en el móvil se pide el permiso (Android 13+ no deja mostrar
  /// avisos sin él). Solo una vez: si lo deniega, los avisos quedan desactivados y se pueden
  /// activar luego en Más.
  Future<void> askOnce() async {
    if (!supported) return;
    try {
      if (!shouldAsk(await _storage.read(key: 'faro.notifications'), await _storage.read(key: _askedKey))) {
        return;
      }
      await _storage.write(key: _askedKey, value: '1');
      await setEnabled(true);
    } catch (_) {}
  }

  static const _askedKey = 'faro.notifications.asked';

  /// Activa o desactiva los avisos (al activar, Android 13+ pide permiso).
  Future<bool> setEnabled(bool on) async {
    if (!supported) return false;
    await _init();
    if (on) {
      final granted = await _android?.requestNotificationsPermission() ?? true;
      if (!granted) on = false;
    } else {
      await _plugin.cancelAll();
    }
    await _storage.write(key: 'faro.notifications', value: on ? '1' : '0');
    return on;
  }

  /// Al cerrar sesión: fuera los avisos (llevan datos del usuario que sale).
  Future<void> cancelAll() async {
    if (!supported || !_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> _at(int id, DateTime when, String title, String body, String route) async {
    final t = tz.TZDateTime(tz.local, when.year, when.month, when.day, when.hour, when.minute);
    if (t.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: t,
      notificationDetails: const NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      payload: route,
    );
  }

  /// Reprograma todo con los datos actuales. Los fallos de un bloque no paran los demás.
  Future<void> reschedule({
    GastosSettingsOut? settings,
    CycleDetailOut? cycle,
    List<PlanOut> plans = const [],
    Map<String, String> assetNames = const {},
    PortfolioOut? portfolio,
  }) async {
    if (!await enabled()) return;
    await _init();
    await _plugin.cancelAll();
    final now = DateTime.now();
    // Las notificaciones no respetan el modo privacidad: nunca llevan importes del patrimonio
    final hidden = privacyMode;

    if (settings != null) {
      final payday = nextPayday(now, settings.paydayDay);
      final eve = payday.subtract(const Duration(days: 1));
      await _at(1, DateTime(eve.year, eve.month, eve.day, 20), 'Mañana cobras',
          'Cuando entre la nómina, pulsa "He cobrado" para abrir el ciclo nuevo.', AvisoRoute.cycle);
      await _at(2, DateTime(payday.year, payday.month, payday.day, 21), 'Ciclo nuevo',
          'Mira cómo te fue el ciclo que acaba y cuánto ahorraste.', AvisoRoute.cycles);
    }
    if (cycle != null) {
      var id = 100;
      final soon = now.add(const Duration(days: 14));
      for (final m in cycle.movements) {
        final due = m.dueDate;
        if (m.status != MovementOutStatusEnum.planned || due == null || due.isAfter(soon)) continue;
        final cuota = m.source_ == 'installment';
        await _at(id++, DateTime(due.year, due.month, due.day, 9), cuota ? 'Hoy se carga una cuota' : 'Cargo previsto hoy',
            hidden ? m.concept : '${m.concept}: ${eur(m.amount)}', AvisoRoute.cycle);
        if (id > 160) break;
      }
    }
    final q = nextQuarterStart(now);
    await _at(4, DateTime(q.year, q.month, q.day, 10), 'Revisión trimestral',
        'Ha terminado el trimestre: repasa en Planes → Revisión cómo fue y qué cambias.', AvisoRoute.review);
    var pid = 200;
    for (final p in plans.where((p) => p.active && p.nextDate != null)) {
      final d = p.nextDate!;
      await _at(pid++, DateTime(d.year, d.month, d.day, 9), 'Aportación periódica',
          '${assetNames[p.assetId] ?? 'Tu plan'}${hidden ? '' : ': ${eur(p.amount)}'}', AvisoRoute.plans);
    }
    if (portfolio != null) {
      final out = portfolio.classes
          .where((c) => c.status == ClassOutStatusEnum.bajo || c.status == ClassOutStatusEnum.alto)
          .map((c) => '${c.assetClass.name} ${c.status == ClassOutStatusEnum.bajo ? 'por debajo' : 'por encima'}')
          .toList();
      final signature = out.join('|');
      final last = await _storage.read(key: 'faro.notifications.rebalance');
      if (out.isNotEmpty && signature != last) {
        final t = now.add(const Duration(minutes: 1));
        await _at(3, t, 'Cartera fuera de rango', '${out.join(', ')}. Mira cómo repartir la próxima aportación.',
            AvisoRoute.contribute);
      }
      await _storage.write(key: 'faro.notifications.rebalance', value: signature);
    }
  }
}

/// Pantalla que abre cada aviso al tocarlo (D12).
abstract final class AvisoRoute {
  static const cycle = '/gastos'; // víspera del cobro, cargos y cuotas del día
  static const cycles = '/gastos/ciclos'; // ciclo nuevo: cómo fue el que acaba
  static const review = '/planes/revision';
  static const plans = '/inversiones/periodicas';
  static const contribute = '/inversiones/aportar'; // cartera fuera de rango
  static const all = [cycle, cycles, review, plans, contribute];
}

/// Solo se abren rutas internas de la app (la ruta va en el aviso, que lo programa la propia app).
bool isAvisoRoute(String? r) => r != null && AvisoRoute.all.contains(r);

/// Próximo cobro estimado: el día de cobro del mes (acotado al fin de mes); si cae en fin de
/// semana, el lunes siguiente. Igual que el backend (`domain/calendar.estimated_payday`).
DateTime nextPayday(DateTime from, int day) {
  DateTime forMonth(int y, int m) {
    final last = DateTime(y, m + 1, 0).day;
    var d = DateTime(y, m, day > last ? last : day);
    while (d.weekday >= DateTime.saturday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  final today = DateTime(from.year, from.month, from.day);
  final thisMonth = forMonth(from.year, from.month);
  return thisMonth.isBefore(today) ? forMonth(from.year, from.month + 1) : thisMonth;
}

/// Avisos activados según lo guardado: por defecto sí, salvo que el usuario los apagara ("0").
bool avisosOn(String? stored) => stored != '0';

/// Pedir el permiso al entrar: solo si nunca se pidió y el usuario no apagó los avisos.
bool shouldAsk(String? stored, String? asked) => asked == null && avisosOn(stored) && stored != '1';

/// Primer día del trimestre siguiente (1 de enero, abril, julio u octubre).
DateTime nextQuarterStart(DateTime from) {
  final m = ((from.month - 1) ~/ 3 + 1) * 3 + 1;
  return m > 12 ? DateTime(from.year + 1, 1, 1) : DateTime(from.year, m, 1);
}

/// Si los avisos están activados (para el interruptor de Más).
class NotificationsController extends Notifier<bool> {
  @override
  bool build() {
    Notifications.instance.enabled().then((v) => state = v);
    return false;
  }

  Future<void> set(bool on) async => state = await Notifications.instance.setEnabled(on);
}

final notificationsProvider = NotifierProvider<NotificationsController, bool>(NotificationsController.new);
