// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_next_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilestoneNextOut _$MilestoneNextOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MilestoneNextOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['amount', 'months', 'eta']);
      final val = MilestoneNextOut(
        amount: $checkedConvert('amount', (v) => v as String),
        months: $checkedConvert('months', (v) => (v as num?)?.toInt()),
        eta: $checkedConvert(
          'eta',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MilestoneNextOutToJson(MilestoneNextOut instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'months': instance.months,
      'eta': instance.eta?.toIso8601String(),
    };
