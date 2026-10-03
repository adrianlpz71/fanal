// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'band_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BandOut _$BandOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BandOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['age', 'p10', 'p50', 'p90']);
      final val = BandOut(
        age: $checkedConvert('age', (v) => (v as num).toInt()),
        p10: $checkedConvert('p10', (v) => v as String),
        p50: $checkedConvert('p50', (v) => v as String),
        p90: $checkedConvert('p90', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$BandOutToJson(BandOut instance) => <String, dynamic>{
  'age': instance.age,
  'p10': instance.p10,
  'p50': instance.p50,
  'p90': instance.p90,
};
