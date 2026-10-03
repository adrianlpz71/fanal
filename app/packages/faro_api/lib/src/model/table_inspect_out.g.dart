// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_inspect_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableInspectOut _$TableInspectOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TableInspectOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['rows', 'suggested', 'message']);
      final val = TableInspectOut(
        rows: $checkedConvert(
          'rows',
          (v) => (v as List<dynamic>)
              .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
              .toList(),
        ),
        suggested: $checkedConvert(
          'suggested',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        message: $checkedConvert('message', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TableInspectOutToJson(TableInspectOut instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'suggested': instance.suggested,
      'message': instance.message,
    };
