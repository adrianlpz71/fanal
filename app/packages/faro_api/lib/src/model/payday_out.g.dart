// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payday_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaydayOut _$PaydayOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PaydayOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'closed_id',
        'opened',
        'discrepancy',
        'carried_over',
        'cancelled',
      ],
    );
    final val = PaydayOut(
      closedId: $checkedConvert('closed_id', (v) => v as String),
      opened: $checkedConvert(
        'opened',
        (v) => CycleOut.fromJson(v as Map<String, dynamic>),
      ),
      discrepancy: $checkedConvert('discrepancy', (v) => v as String),
      carriedOver: $checkedConvert('carried_over', (v) => (v as num).toInt()),
      cancelled: $checkedConvert('cancelled', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'closedId': 'closed_id', 'carriedOver': 'carried_over'},
);

Map<String, dynamic> _$PaydayOutToJson(PaydayOut instance) => <String, dynamic>{
  'closed_id': instance.closedId,
  'opened': instance.opened.toJson(),
  'discrepancy': instance.discrepancy,
  'carried_over': instance.carriedOver,
  'cancelled': instance.cancelled,
};
