// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_detail_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleDetailOut _$CycleDetailOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CycleDetailOut',
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
            'movements',
          ],
        );
        final val = CycleDetailOut(
          id: $checkedConvert('id', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$CycleDetailOutStatusEnumEnumMap, v),
          ),
          startDate: $checkedConvert(
            'start_date',
            (v) => DateTime.parse(v as String),
          ),
          endDate: $checkedConvert(
            'end_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          carriedExpected: $checkedConvert(
            'carried_expected',
            (v) => v as String?,
          ),
          discrepancy: $checkedConvert('discrepancy', (v) => v as String?),
          summary: $checkedConvert(
            'summary',
            (v) => CycleSummaryOut.fromJson(v as Map<String, dynamic>),
          ),
          movements: $checkedConvert(
            'movements',
            (v) => (v as List<dynamic>)
                .map((e) => MovementOut.fromJson(e as Map<String, dynamic>))
                .toList(),
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

Map<String, dynamic> _$CycleDetailOutToJson(CycleDetailOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'status': _$CycleDetailOutStatusEnumEnumMap[instance.status]!,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'carried_expected': instance.carriedExpected,
      'discrepancy': instance.discrepancy,
      'summary': instance.summary.toJson(),
      'movements': instance.movements.map((e) => e.toJson()).toList(),
    };

const _$CycleDetailOutStatusEnumEnumMap = {
  CycleDetailOutStatusEnum.open: 'open',
  CycleDetailOutStatusEnum.closed: 'closed',
};
