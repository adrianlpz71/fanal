// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonOut _$PersonOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PersonOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'notes',
          'archived',
          'owed_to_me',
          'i_owe',
          'net',
        ],
      );
      final val = PersonOut(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        notes: $checkedConvert('notes', (v) => v as String?),
        archived: $checkedConvert('archived', (v) => v as bool),
        owedToMe: $checkedConvert('owed_to_me', (v) => v as String),
        iOwe: $checkedConvert('i_owe', (v) => v as String),
        net: $checkedConvert('net', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'owedToMe': 'owed_to_me', 'iOwe': 'i_owe'});

Map<String, dynamic> _$PersonOutToJson(PersonOut instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'notes': instance.notes,
  'archived': instance.archived,
  'owed_to_me': instance.owedToMe,
  'i_owe': instance.iOwe,
  'net': instance.net,
};
