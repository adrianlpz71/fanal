// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_target_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetTargetOut _$AssetTargetOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetTargetOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['asset_id', 'target', 'valid_from'],
      );
      final val = AssetTargetOut(
        assetId: $checkedConvert('asset_id', (v) => v as String),
        target: $checkedConvert('target', (v) => v as String),
        validFrom: $checkedConvert(
          'valid_from',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'assetId': 'asset_id', 'validFrom': 'valid_from'});

Map<String, dynamic> _$AssetTargetOutToJson(AssetTargetOut instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'target': instance.target,
      'valid_from': instance.validFrom.toIso8601String(),
    };
