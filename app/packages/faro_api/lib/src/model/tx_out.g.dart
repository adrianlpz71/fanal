// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxOut _$TxOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TxOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'asset_id',
        'kind',
        'status',
        'trade_date',
        'settle_date',
        'amount_eur',
        'units',
        'price',
        'avg_cost',
        'fee',
        'pair_id',
        'movement_id',
        'notes',
      ],
    );
    final val = TxOut(
      id: $checkedConvert('id', (v) => v as String),
      assetId: $checkedConvert('asset_id', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$TxOutKindEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$TxOutStatusEnumEnumMap, v),
      ),
      tradeDate: $checkedConvert(
        'trade_date',
        (v) => DateTime.parse(v as String),
      ),
      settleDate: $checkedConvert(
        'settle_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      amountEur: $checkedConvert('amount_eur', (v) => v as String),
      units: $checkedConvert('units', (v) => v as String?),
      price: $checkedConvert('price', (v) => v as String?),
      avgCost: $checkedConvert('avg_cost', (v) => v as String?),
      fee: $checkedConvert('fee', (v) => v as String),
      pairId: $checkedConvert('pair_id', (v) => v as String?),
      movementId: $checkedConvert('movement_id', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetId': 'asset_id',
    'tradeDate': 'trade_date',
    'settleDate': 'settle_date',
    'amountEur': 'amount_eur',
    'avgCost': 'avg_cost',
    'pairId': 'pair_id',
    'movementId': 'movement_id',
  },
);

Map<String, dynamic> _$TxOutToJson(TxOut instance) => <String, dynamic>{
  'id': instance.id,
  'asset_id': instance.assetId,
  'kind': _$TxOutKindEnumEnumMap[instance.kind]!,
  'status': _$TxOutStatusEnumEnumMap[instance.status]!,
  'trade_date': instance.tradeDate.toIso8601String(),
  'settle_date': instance.settleDate?.toIso8601String(),
  'amount_eur': instance.amountEur,
  'units': instance.units,
  'price': instance.price,
  'avg_cost': instance.avgCost,
  'fee': instance.fee,
  'pair_id': instance.pairId,
  'movement_id': instance.movementId,
  'notes': instance.notes,
};

const _$TxOutKindEnumEnumMap = {
  TxOutKindEnum.posicionInicial: 'posicion_inicial',
  TxOutKindEnum.compra: 'compra',
  TxOutKindEnum.venta: 'venta',
  TxOutKindEnum.aportacionPeriodica: 'aportacion_periodica',
  TxOutKindEnum.traspasoSalida: 'traspaso_salida',
  TxOutKindEnum.traspasoEntrada: 'traspaso_entrada',
  TxOutKindEnum.dividendo: 'dividendo',
  TxOutKindEnum.interes: 'interes',
  TxOutKindEnum.comision: 'comision',
  TxOutKindEnum.recompensa: 'recompensa',
};

const _$TxOutStatusEnumEnumMap = {
  TxOutStatusEnum.pendienteVl: 'pendiente_vl',
  TxOutStatusEnum.liquidada: 'liquidada',
  TxOutStatusEnum.cancelada: 'cancelada',
};
