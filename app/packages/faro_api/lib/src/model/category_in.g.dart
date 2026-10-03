// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryIn _$CategoryInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = CategoryIn(
        parentId: $checkedConvert('parent_id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecodeNullable(_$CategoryInKindEnumEnumMap, v),
        ),
        icon: $checkedConvert('icon', (v) => v as String? ?? 'category'),
        color: $checkedConvert('color', (v) => v as String? ?? '#607D8B'),
        fixed: $checkedConvert('fixed', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'parentId': 'parent_id'});

Map<String, dynamic> _$CategoryInToJson(CategoryIn instance) =>
    <String, dynamic>{
      'parent_id': ?instance.parentId,
      'name': instance.name,
      'kind': ?_$CategoryInKindEnumEnumMap[instance.kind],
      'icon': ?instance.icon,
      'color': ?instance.color,
      'fixed': ?instance.fixed,
    };

const _$CategoryInKindEnumEnumMap = {
  CategoryInKindEnum.gasto: 'gasto',
  CategoryInKindEnum.ingreso: 'ingreso',
  CategoryInKindEnum.transferencia: 'transferencia',
};
