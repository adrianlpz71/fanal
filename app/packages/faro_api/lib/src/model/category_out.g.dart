// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryOut _$CategoryOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'parent_id',
          'name',
          'kind',
          'icon',
          'color',
          'fixed',
          'archived',
        ],
      );
      final val = CategoryOut(
        id: $checkedConvert('id', (v) => v as String),
        parentId: $checkedConvert('parent_id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert('kind', (v) => v as String),
        icon: $checkedConvert('icon', (v) => v as String),
        color: $checkedConvert('color', (v) => v as String),
        fixed: $checkedConvert('fixed', (v) => v as bool),
        archived: $checkedConvert('archived', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'parentId': 'parent_id'});

Map<String, dynamic> _$CategoryOutToJson(CategoryOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'name': instance.name,
      'kind': instance.kind,
      'icon': instance.icon,
      'color': instance.color,
      'fixed': instance.fixed,
      'archived': instance.archived,
    };
