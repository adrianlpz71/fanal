import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/notifications.dart';
import 'core/offline.dart';
import 'core/privacy.dart';
import 'core/share_intake.dart';
import 'core/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/gastos/data.dart';
import 'features/inversiones/data.dart';
import 'features/inversiones/plans_page.dart' show contributionPlansProvider;
import 'features/more/more_page.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  await initializeDateFormatting('es_ES');
  runApp(const ProviderScope(retry: retryPolicy, child: FaroApp()));
}

/// Riverpod 3 reintenta solo los providers que fallan. Solo tiene sentido con errores que pueden
/// arreglarse solos (red, 5xx); sin sesión o con un 4xx, reintentar solo repite el error.
Duration? retryPolicy(int retryCount, Object error) {
  if (error is NotSignedIn) return null;
  final status = error is DioException ? error.response?.statusCode : null;
  if (status != null && status >= 400 && status < 500) return null;
  if (retryCount >= 5) return null;
  return Duration(milliseconds: 400 * (1 << retryCount));
}

class FaroApp extends ConsumerStatefulWidget {
  const FaroApp({super.key});

  @override
  ConsumerState<FaroApp> createState() => _FaroAppState();
}

class _FaroAppState extends ConsumerState<FaroApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => initShareIntake(ref));
    Notifications.instance.tapped.addListener(_openTappedAviso);
    Notifications.instance.listenTaps();
  }

  @override
  void dispose() {
    Notifications.instance.tapped.removeListener(_openTappedAviso);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Navega a la pantalla del aviso tocado. Si aún no hay sesión (arranque, bloqueo, 2FA), espera:
  /// se vuelve a llamar cuando cambia el estado de la sesión.
  void _openTappedAviso() {
    final route = Notifications.instance.tapped.value;
    if (route == null) return;
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated || !auth.user.onboardingCompleted) return;
    Notifications.instance.tapped.value = null;
    if (!isAvisoRoute(route)) return;
    // Después del frame: el redirect de entrada (splash → /gastos) ya se ha aplicado
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(routerProvider).go(route));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = ref.read(authProvider.notifier);
    if (state == AppLifecycleState.paused) auth.onPaused();
    if (state == AppLifecycleState.resumed) auth.onResumed();
    if (state == AppLifecycleState.resumed) ref.read(pendingMovementsProvider.notifier).flush();
  }

  @override
  Widget build(BuildContext context) {
    // Un fichero compartido desde otra app abre la pantalla de importación
    ref.listen(sharedFileProvider, (prev, next) {
      if (next != null) ref.read(routerProvider).go('/compartido');
    });
    // Un aviso tocado abre su pantalla en cuanto hay sesión (tras el desbloqueo, si lo hay)
    ref.listen(authProvider, (prev, next) => _openTappedAviso());
    // Primera vez con sesión en el móvil: se pide el permiso de avisos (Android 13+ lo exige)
    ref.listen(sessionUserIdProvider, (prev, next) async {
      if (!Notifications.supported || next == null) return;
      await Notifications.instance.askOnce();
      ref.invalidate(notificationsProvider);
    });
    // Cada vez que llega el ciclo actual se reprograman los avisos (solo Android)
    ref.listen(currentCycleProvider, (prev, next) {
      final cycle = next.value;
      if (Notifications.supported && cycle != null) _rescheduleNotifications(cycle);
    });
    return MaterialApp.router(
      title: 'Fanal',
      debugShowCheckedModeBanner: false,
      theme: FaroTheme.light(),
      darkTheme: FaroTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
      // Al cambiar el modo privacidad se reconstruye todo para que ningún importe se quede visible
      builder: (context, child) => KeyedSubtree(key: ValueKey(ref.watch(privacyProvider)), child: child!),
    );
  }
}

extension on _FaroAppState {
  Future<void> _rescheduleNotifications(CycleDetailOut cycle) async {
    Future<T?> safe<T>(Future<T> f) async {
      try {
        return await f;
      } catch (_) {
        return null;
      }
    }

    final settings = await safe(ref.read(gastosSettingsProvider.future));
    final plans = await safe(ref.read(contributionPlansProvider.future)) ?? const <PlanOut>[];
    final assets = await safe(ref.read(assetsProvider.future)) ?? const <AssetOut>[];
    final portfolio = await safe(ref.read(portfolioProvider.future));
    await safe(Notifications.instance.reschedule(
      settings: settings,
      cycle: cycle,
      plans: plans,
      assetNames: {for (final a in assets) a.id: a.name},
      portfolio: portfolio,
    ));
  }
}
