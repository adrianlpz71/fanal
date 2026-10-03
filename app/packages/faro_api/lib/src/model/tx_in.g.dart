// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxIn _$TxInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TxIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['asset_id', 'kind', 'trade_date']);
    final val = TxIn(
      id: $checkedConvert('id', (v) => v as String?),
      assetId: $checkedConvert('asset_id', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$TxInKindEnumEnumMap, v),
      ),
      tradeDate: $checkedConvert(
        'trade_date',
        (v) => DateTime.parse(v as String),
      ),
      amountEur: $checkedConvert('amount_eur', (v) => v as String? ?? '0'),
      units: $checkedConvert('units', (v) => v as String?),
      price: $checkedConvert('price', (v) => v as String?),
      avgCost: $checkedConvert('avg_cost', (v) => v as String?),
      fee: $checkedConvert('fee', (v) => v as String? ?? '0'),
      pending: $checkedConvert('pending', (v) => v as bool? ?? false),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetId': 'asset_id',
    'tradeDate': 'trade_date',
    'amountEur': 'amount_eur',
    'avgCost': 'avg_cost',
  },
);

Map<String, dynamic> _$TxInToJson(TxIn instance) => <String, dynamic>{
  'id': ?instance.id,
  'asset_id': instance.assetId,
  'kind': _$TxInKindEnumEnumMap[instance.kind]!,
  'trade_date': instance.tradeDate.toIso8601String(),
  'amount_eur': ?instance.amountEur,
  'units': ?instance.units,
  'price': ?instance.price,
  'avg_cost': ?instance.avgCost,
  'fee': ?instance.fee,
  'pending': ?instance.pending,
  'notes': ?instance.notes,
};

const _$TxInKindEnumEnumMap = {
  TxInKindEnum.posicionInicial: 'posicion_inicial',
  TxInKindEnum.compra: 'compra',
  TxInKindEnum.venta: 'venta',
  TxInKindEnum.aportacionPeriodica: 'aportacion_periodica',
  TxInKindEnum.traspasoSalida: 'traspaso_salida',
  TxInKindEnum.traspasoEntrada: 'traspaso_entrada',
  TxInKindEnum.dividendo: 'dividendo',
  TxInKindEnum.interes: 'interes',
  TxInKindEnum.comision: 'comision',
  TxInKindEnum.recompensa: 'recompensa',
};
