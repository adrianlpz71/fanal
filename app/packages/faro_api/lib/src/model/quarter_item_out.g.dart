// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarter_item_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarterItemOut _$QuarterItemOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QuarterItemOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['quarter', 'label', 'in_progress', 'saved'],
      );
      final val = QuarterItemOut(
        quarter: $checkedConvert('quarter', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        inProgress: $checkedConvert('in_progress', (v) => v as bool),
        saved: $checkedConvert('saved', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'inProgress': 'in_progress'});

Map<String, dynamic> _$QuarterItemOutToJson(QuarterItemOut instance) =>
    <String, dynamic>{
      'quarter': instance.quarter,
      'label': instance.label,
      'in_progress': instance.inProgress,
      'saved': instance.saved,
    };
