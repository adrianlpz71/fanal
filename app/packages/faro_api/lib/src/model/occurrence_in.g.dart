// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrence_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OccurrenceIn _$OccurrenceInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OccurrenceIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'action']);
      final val = OccurrenceIn(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$OccurrenceInActionEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OccurrenceInToJson(OccurrenceIn instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'action': _$OccurrenceInActionEnumEnumMap[instance.action]!,
    };

const _$OccurrenceInActionEnumEnumMap = {
  OccurrenceInActionEnum.editar: 'editar',
  OccurrenceInActionEnum.saltar: 'saltar',
};
