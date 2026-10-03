// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_asset_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewAssetOut _$NewAssetOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NewAssetOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'name']);
      final val = NewAssetOut(
        key: $checkedConvert('key', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$NewAssetOutToJson(NewAssetOut instance) =>
    <String, dynamic>{'key': instance.key, 'name': instance.name};
