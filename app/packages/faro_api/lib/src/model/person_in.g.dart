// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonIn _$PersonInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PersonIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name']);
      final val = PersonIn(
        name: $checkedConvert('name', (v) => v as String),
        notes: $checkedConvert('notes', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PersonInToJson(PersonIn instance) => <String, dynamic>{
  'name': instance.name,
  'notes': ?instance.notes,
};
