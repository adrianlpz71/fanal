// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderOut _$OrderOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'OrderOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'asset_id',
        'asset_name',
        'amount',
        'price',
        'approx_units',
      ],
    );
    final val = OrderOut(
      assetId: $checkedConvert('asset_id', (v) => v as String),
      assetName: $checkedConvert('asset_name', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      price: $checkedConvert('price', (v) => v as String?),
      approxUnits: $checkedConvert('approx_units', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetId': 'asset_id',
    'assetName': 'asset_name',
    'approxUnits': 'approx_units',
  },
);

Map<String, dynamic> _$OrderOutToJson(OrderOut instance) => <String, dynamic>{
  'asset_id': instance.assetId,
  'asset_name': instance.assetName,
  'amount': instance.amount,
  'price': instance.price,
  'approx_units': instance.approxUnits,
};
