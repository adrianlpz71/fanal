// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryPatch _$CategoryPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryPatch', json, ($checkedConvert) {
      final val = CategoryPatch(
        name: $checkedConvert('name', (v) => v as String?),
        icon: $checkedConvert('icon', (v) => v as String?),
        color: $checkedConvert('color', (v) => v as String?),
        fixed: $checkedConvert('fixed', (v) => v as bool?),
        archived: $checkedConvert('archived', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$CategoryPatchToJson(CategoryPatch instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'icon': ?instance.icon,
      'color': ?instance.color,
      'fixed': ?instance.fixed,
      'archived': ?instance.archived,
    };
