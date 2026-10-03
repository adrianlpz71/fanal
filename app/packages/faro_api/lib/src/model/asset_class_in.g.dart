// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_class_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetClassIn _$AssetClassInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetClassIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = AssetClassIn(
        name: $checkedConvert('name', (v) => v as String),
        defaultTolerancePp: $checkedConvert(
          'default_tolerance_pp',
          (v) => v as String? ?? '1',
        ),
      );
      return val;
    }, fieldKeyMap: const {'defaultTolerancePp': 'default_tolerance_pp'});

Map<String, dynamic> _$AssetClassInToJson(AssetClassIn instance) =>
    <String, dynamic>{
      'name': instance.name,
      'default_tolerance_pp': ?instance.defaultTolerancePp,
    };
