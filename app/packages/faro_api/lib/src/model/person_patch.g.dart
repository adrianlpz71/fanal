// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonPatch _$PersonPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PersonPatch', json, ($checkedConvert) {
      final val = PersonPatch(
        name: $checkedConvert('name', (v) => v as String?),
        notes: $checkedConvert('notes', (v) => v as String?),
        archived: $checkedConvert('archived', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$PersonPatchToJson(PersonPatch instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'notes': ?instance.notes,
      'archived': ?instance.archived,
    };
