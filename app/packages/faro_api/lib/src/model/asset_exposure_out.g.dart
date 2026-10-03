// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_exposure_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetExposureOut _$AssetExposureOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetExposureOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['dimension', 'key', 'weight', 'source', 'as_of'],
      );
      final val = AssetExposureOut(
        dimension: $checkedConvert('dimension', (v) => v as String),
        key: $checkedConvert('key', (v) => v as String),
        weight: $checkedConvert('weight', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String),
        asOf: $checkedConvert(
          'as_of',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source', 'asOf': 'as_of'});

Map<String, dynamic> _$AssetExposureOutToJson(AssetExposureOut instance) =>
    <String, dynamic>{
      'dimension': instance.dimension,
      'key': instance.key,
      'weight': instance.weight,
      'source': instance.source_,
      'as_of': instance.asOf?.toIso8601String(),
    };
