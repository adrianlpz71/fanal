// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleOut _$CycleOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CycleOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'label',
        'status',
        'start_date',
        'end_date',
        'carried_expected',
        'discrepancy',
        'summary',
      ],
    );
    final val = CycleOut(
      id: $checkedConvert('id', (v) => v as String),
      label: $checkedConvert('label', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$CycleOutStatusEnumEnumMap, v),
      ),
      startDate: $checkedConvert(
        'start_date',
        (v) => DateTime.parse(v as String),
      ),
      endDate: $checkedConvert(
        'end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      carriedExpected: $checkedConvert('carried_expected', (v) => v as String?),
      discrepancy: $checkedConvert('discrepancy', (v) => v as String?),
      summary: $checkedConvert(
        'summary',
        (v) => CycleSummaryOut.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'startDate': 'start_date',
    'endDate': 'end_date',
    'carriedExpected': 'carried_expected',
  },
);

Map<String, dynamic> _$CycleOutToJson(CycleOut instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'status': _$CycleOutStatusEnumEnumMap[instance.status]!,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'carried_expected': instance.carriedExpected,
  'discrepancy': instance.discrepancy,
  'summary': instance.summary.toJson(),
};

const _$CycleOutStatusEnumEnumMap = {
  CycleOutStatusEnum.open: 'open',
  CycleOutStatusEnum.closed: 'closed',
};
