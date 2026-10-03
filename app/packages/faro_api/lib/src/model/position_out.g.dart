// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionOut _$PositionOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PositionOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'asset',
        'units',
        'avg_cost',
        'cost',
        'price',
        'price_date',
        'price_source',
        'stale',
        'value',
        'pnl',
        'pnl_pct',
        'pending',
        'inner_weight',
        'inner_target',
        'inner_status',
      ],
    );
    final val = PositionOut(
      asset: $checkedConvert(
        'asset',
        (v) => AssetOut.fromJson(v as Map<String, dynamic>),
      ),
      units: $checkedConvert('units', (v) => v as String),
      avgCost: $checkedConvert('avg_cost', (v) => v as String),
      cost: $checkedConvert('cost', (v) => v as String),
      price: $checkedConvert('price', (v) => v as String?),
      priceDate: $checkedConvert(
        'price_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      priceSource: $checkedConvert('price_source', (v) => v as String?),
      stale: $checkedConvert('stale', (v) => v as bool),
      value: $checkedConvert('value', (v) => v as String),
      pnl: $checkedConvert('pnl', (v) => v as String),
      pnlPct: $checkedConvert('pnl_pct', (v) => v as String?),
      pending: $checkedConvert('pending', (v) => v as String),
      innerWeight: $checkedConvert('inner_weight', (v) => v as String),
      innerTarget: $checkedConvert('inner_target', (v) => v as String?),
      innerStatus: $checkedConvert(
        'inner_status',
        (v) => $enumDecodeNullable(_$PositionOutInnerStatusEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'avgCost': 'avg_cost',
    'priceDate': 'price_date',
    'priceSource': 'price_source',
    'pnlPct': 'pnl_pct',
    'innerWeight': 'inner_weight',
    'innerTarget': 'inner_target',
    'innerStatus': 'inner_status',
  },
);

Map<String, dynamic> _$PositionOutToJson(PositionOut instance) =>
    <String, dynamic>{
      'asset': instance.asset.toJson(),
      'units': instance.units,
      'avg_cost': instance.avgCost,
      'cost': instance.cost,
      'price': instance.price,
      'price_date': instance.priceDate?.toIso8601String(),
      'price_source': instance.priceSource,
      'stale': instance.stale,
      'value': instance.value,
      'pnl': instance.pnl,
      'pnl_pct': instance.pnlPct,
      'pending': instance.pending,
      'inner_weight': instance.innerWeight,
      'inner_target': instance.innerTarget,
      'inner_status': _$PositionOutInnerStatusEnumEnumMap[instance.innerStatus],
    };

const _$PositionOutInnerStatusEnumEnumMap = {
  PositionOutInnerStatusEnum.comprar: 'comprar',
  PositionOutInnerStatusEnum.noComprar: 'no_comprar',
  PositionOutInnerStatusEnum.ok: 'ok',
};
