// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LotOut _$LotOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LotOut',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['acquired', 'units', 'cost']);
    final val = LotOut(
      acquired: $checkedConvert('acquired', (v) => DateTime.parse(v as String)),
      units: $checkedConvert('units', (v) => v as String),
      cost: $checkedConvert('cost', (v) => v as String),
    );
    return val;
  },
);

Map<String, dynamic> _$LotOutToJson(LotOut instance) => <String, dynamic>{
  'acquired': instance.acquired.toIso8601String(),
  'units': instance.units,
  'cost': instance.cost,
};
