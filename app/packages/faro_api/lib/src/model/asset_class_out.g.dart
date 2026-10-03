// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_class_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetClassOut _$AssetClassOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetClassOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'default_tolerance_pp', 'sort'],
      );
      final val = AssetClassOut(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        defaultTolerancePp: $checkedConvert(
          'default_tolerance_pp',
          (v) => v as String,
        ),
        sort: $checkedConvert('sort', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'defaultTolerancePp': 'default_tolerance_pp'});

Map<String, dynamic> _$AssetClassOutToJson(AssetClassOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'default_tolerance_pp': instance.defaultTolerancePp,
      'sort': instance.sort,
    };
