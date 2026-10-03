// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_target_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetTargetIn _$AssetTargetInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetTargetIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['asset_id', 'target']);
      final val = AssetTargetIn(
        assetId: $checkedConvert('asset_id', (v) => v as String),
        target: $checkedConvert('target', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'assetId': 'asset_id'});

Map<String, dynamic> _$AssetTargetInToJson(AssetTargetIn instance) =>
    <String, dynamic>{'asset_id': instance.assetId, 'target': instance.target};
