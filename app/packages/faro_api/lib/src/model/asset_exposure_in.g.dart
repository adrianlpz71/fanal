// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_exposure_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetExposureIn _$AssetExposureInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetExposureIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['dimension', 'key', 'weight']);
      final val = AssetExposureIn(
        dimension: $checkedConvert(
          'dimension',
          (v) => $enumDecode(_$AssetExposureInDimensionEnumEnumMap, v),
        ),
        key: $checkedConvert('key', (v) => v as String),
        weight: $checkedConvert('weight', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AssetExposureInToJson(AssetExposureIn instance) =>
    <String, dynamic>{
      'dimension': _$AssetExposureInDimensionEnumEnumMap[instance.dimension]!,
      'key': instance.key,
      'weight': instance.weight,
    };

const _$AssetExposureInDimensionEnumEnumMap = {
  AssetExposureInDimensionEnum.sector: 'sector',
  AssetExposureInDimensionEnum.region: 'region',
  AssetExposureInDimensionEnum.pais: 'pais',
};
