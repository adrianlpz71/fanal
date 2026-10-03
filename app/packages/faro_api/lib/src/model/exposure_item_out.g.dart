// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exposure_item_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExposureItemOut _$ExposureItemOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExposureItemOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'weight', 'value']);
      final val = ExposureItemOut(
        key: $checkedConvert('key', (v) => v as String),
        weight: $checkedConvert('weight', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExposureItemOutToJson(ExposureItemOut instance) =>
    <String, dynamic>{
      'key': instance.key,
      'weight': instance.weight,
      'value': instance.value,
    };
