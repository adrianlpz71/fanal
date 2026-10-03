// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_start_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleStartIn _$CycleStartInFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CycleStartIn',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['current_balance']);
        final val = CycleStartIn(
          currentBalance: $checkedConvert(
            'current_balance',
            (v) => v as String,
          ),
          payrollAmount: $checkedConvert(
            'payroll_amount',
            (v) => v as String? ?? '0',
          ),
          payrollDate: $checkedConvert(
            'payroll_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'currentBalance': 'current_balance',
        'payrollAmount': 'payroll_amount',
        'payrollDate': 'payroll_date',
      },
    );

Map<String, dynamic> _$CycleStartInToJson(CycleStartIn instance) =>
    <String, dynamic>{
      'current_balance': instance.currentBalance,
      'payroll_amount': ?instance.payrollAmount,
      'payroll_date': ?instance.payrollDate?.toIso8601String(),
    };
