import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart' show userApi;
import '../../core/components/indicators.dart';
import '../../core/money.dart';
import '../../core/tokens.dart';

InversionesApi _api(Ref ref) => userApi(ref).getInversionesApi();

final invSettingsProvider = FutureProvider<InvSettingsOut>((ref) async => (await _api(ref).getSettings()).data!);
final portfolioProvider = FutureProvider<PortfolioOut>((ref) async => (await _api(ref).getPortfolio()).data!);
final assetClassesProvider =
    FutureProvider<List<AssetClassOut>>((ref) async => (await _api(ref).listClasses()).data!);
final platformsProvider = FutureProvider<List<PlatformOut>>((ref) async => (await _api(ref).listPlatforms()).data!);
final assetsProvider = FutureProvider<List<AssetOut>>((ref) async => (await _api(ref).listAssets()).data!);
final targetsProvider = FutureProvider<TargetsOut>((ref) async => (await _api(ref).getTargets()).data!);
final assetDetailProvider = FutureProvider.family<AssetDetailOut, String>(
  (ref, id) async => (await _api(ref).assetDetail(assetId: id)).data!,
);
final pendingTxProvider =
    FutureProvider<List<TxOut>>((ref) async => (await _api(ref).listTransactions(pendingOnly: true)).data!);

/// Historial de aportaciones (inversiones y ahorro), con ritmo mensual y racha.
final contributionsProvider = FutureProvider<ContributionsOut>(
  (ref) async => (await userApi(ref).getAnalyticsApi().getContributions()).data!,
);

/// Tras cualquier cambio en inversiones.
void refreshInv(WidgetRef ref) {
  for (final p in [
    invSettingsProvider, portfolioProvider, assetClassesProvider, platformsProvider, assetsProvider,
    targetsProvider, pendingTxProvider, contributionsProvider,
  ]) {
    ref.invalidate(p);
  }
  ref.invalidate(assetDetailProvider);
}

final _hundred = Decimal.fromInt(100);

/// Tanto por uno → "91,62 %".
String pct(String? fraction, {int decimals = 2, bool plus = false}) {
  if (fraction == null) return '—';
  final v = dec(fraction) * _hundred;
  final s = v.toStringAsFixed(decimals).replaceAll('.', ',');
  return '${plus && v > Decimal.zero ? '+' : ''}${withMinus(s)} %';
}

/// "91,62" (en %) → "0.9162" para la API.
String? fractionFromPct(String text) {
  final v = parseEsDecimal(text);
  if (v == null) return null;
  return (v / _hundred).toDecimal(scaleOnInfinitePrecision: 6).toString();
}

/// Cantidades (participaciones, precios) con coma decimal y sin ceros sobrantes.
String qty(String? s) => s == null ? '—' : s.replaceAll('.', ',');

/// Precio por participación para leer: como mucho 4 decimales y el "€" pegado (no se parte de línea).
/// El valor exacto se ve al editar.
String unitPrice(String? s) {
  if (s == null) return '—';
  final d = dec(s);
  return '${qty(d.scale > 4 ? d.round(scale: 4).toString() : s)}\u00a0€';
}

/// Estado con vocabulario único y en lenguaje claro (docs/06-rediseno-ui.md §5.3). Nunca dice qué
/// comprar: describe dónde está cada cosa frente a tus objetivos.
typedef PlainState = ({String label, PillTone tone, String detail});

String _pp(Decimal d) => '${d > Decimal.zero ? '+' : '−'}${d.abs().toStringAsFixed(1).replaceAll('.', ',')} pp';

/// Una categoría frente a su rango (mínimo–máximo).
PlainState? classState(ClassOut c) {
  if (c.status == null || c.target == null) return null;
  final w = dec(c.weight) * _hundred;
  final lo = dec(c.min) * _hundred;
  final hi = dec(c.max) * _hundred;
  return switch (c.status!) {
    ClassOutStatusEnum.bajo => (label: 'Por debajo del rango', tone: PillTone.below, detail: '${_pp(w - lo)} hasta el mínimo'),
    ClassOutStatusEnum.alto => (label: 'Por encima del rango', tone: PillTone.above, detail: '${_pp(w - hi)} sobre el máximo'),
    ClassOutStatusEnum.ok => (
        label: 'Dentro del rango',
        tone: PillTone.ok,
        detail: 'rango ${pct(c.min, decimals: 0)}–${pct(c.max, decimals: 0)}',
      ),
  };
}

/// Un activo frente a su objetivo dentro de la categoría.
PlainState? positionState(PositionOut x) {
  if (x.innerStatus == null || x.innerTarget == null) return null;
  final d = (dec(x.innerWeight) - dec(x.innerTarget)) * _hundred;
  return switch (x.innerStatus!) {
    PositionOutInnerStatusEnum.comprar => (
        label: 'Por debajo del objetivo',
        tone: PillTone.below,
        detail: '${_pp(d)} · la próxima aportación va aquí',
      ),
    PositionOutInnerStatusEnum.noComprar => (
        label: 'Por encima del objetivo',
        tone: PillTone.above,
        detail: '${_pp(d)} · no recibe aportación hasta acercarse',
      ),
    PositionOutInnerStatusEnum.ok => (label: 'En su objetivo', tone: PillTone.ok, detail: 'dentro de la tolerancia'),
  };
}

const assetTypeLabels = {
  AssetInTypeEnum.fondo: 'Fondo',
  AssetInTypeEnum.etf: 'ETF',
  AssetInTypeEnum.accion: 'Acción',
  AssetInTypeEnum.cripto: 'Cripto',
  AssetInTypeEnum.cuenta: 'Cuenta remunerada',
  AssetInTypeEnum.otro: 'Otro',
};

/// Tipos de plataforma (`PLATFORM_KINDS` del backend) con su nombre para la pantalla.
const platformKindLabels = {
  PlatformInKindEnum.broker: 'Bróker',
  PlatformInKindEnum.exchange: 'Exchange de cripto',
  PlatformInKindEnum.banco: 'Banco',
  PlatformInKindEnum.otro: 'Otra',
};

/// Nombre del tipo de una plataforma desde su valor de la API ("broker" → "Bróker").
String platformKindLabel(String value) =>
    platformKindLabels.entries.where((e) => e.key.value == value).firstOrNull?.value ?? value;

const txKindLabels = {
  TxInKindEnum.compra: 'Compra',
  TxInKindEnum.venta: 'Venta',
  TxInKindEnum.aportacionPeriodica: 'Aportación periódica',
  TxInKindEnum.posicionInicial: 'Posición inicial',
  TxInKindEnum.dividendo: 'Dividendo',
  TxInKindEnum.interes: 'Interés',
  TxInKindEnum.comision: 'Comisión',
  TxInKindEnum.recompensa: 'Recompensa / staking',
};

String txKindLabel(TxOutKindEnum k) => switch (k) {
      TxOutKindEnum.posicionInicial => 'Posición inicial',
      TxOutKindEnum.compra => 'Compra',
      TxOutKindEnum.venta => 'Venta',
      TxOutKindEnum.aportacionPeriodica => 'Aportación periódica',
      TxOutKindEnum.traspasoSalida => 'Traspaso (salida)',
      TxOutKindEnum.traspasoEntrada => 'Traspaso (entrada)',
      TxOutKindEnum.dividendo => 'Dividendo',
      TxOutKindEnum.interes => 'Interés',
      TxOutKindEnum.comision => 'Comisión',
      TxOutKindEnum.recompensa => 'Recompensa',
    };

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, maxLines: 1, softWrap: false, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

/// Aviso fijo: la app calcula, no aconseja.
class NoAdviceNote extends StatelessWidget {
  const NoAdviceNote({super.key, this.text, this.infoTitle, this.info});
  final String? text;

  /// Detalle en una ⓘ al final de la nota (así la nota queda en una o dos líneas).
  final String? infoTitle;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final note = Text(
      text ??
          'Fanal solo hace cálculos con tus datos y tus objetivos. No es una recomendación de '
              'inversión.',
      style: Theme.of(context).textTheme.bodySmall,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: info == null
          ? note
          : Row(spacing: Space.xs, children: [
              Expanded(child: note),
              InfoTip('', title: infoTitle ?? 'Más detalle', text: info),
            ]),
    );
  }
}

/// Una categoría se enseña si tiene dinero (o órdenes pendientes) o un objetivo mayor que 0. Con
/// objetivo 0 % y sin posiciones no aporta nada.
bool showClass(ClassOut c) =>
    dec(c.value) > Decimal.zero || dec(c.pending) > Decimal.zero || (c.target != null && dec(c.target) > Decimal.zero);

/// Un activo se enseña si tiene posición o pendientes, o si tiene objetivo dentro de una categoría
/// que también lo tiene (es una compra prevista).
bool showPosition(ClassOut c, PositionOut x) =>
    dec(x.units) > Decimal.zero ||
    dec(x.pending) > Decimal.zero ||
    (x.innerTarget != null &&
        dec(x.innerTarget) > Decimal.zero &&
        c.target != null &&
        dec(c.target) > Decimal.zero);
