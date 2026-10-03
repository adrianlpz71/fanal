// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payday_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaydayIn _$PaydayInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PaydayIn',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'payroll_amount',
        'payroll_date',
        'real_balance_before',
      ],
    );
    final val = PaydayIn(
      payrollAmount: $checkedConvert('payroll_amount', (v) => v as String),
      payrollDate: $checkedConvert(
        'payroll_date',
        (v) => DateTime.parse(v as String),
      ),
      realBalanceBefore: $checkedConvert(
        'real_balance_before',
        (v) => v as String,
      ),
      pendingActions: $checkedConvert(
        'pending_actions',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) =>
              MapEntry(k, $enumDecode(_$PaydayInPendingActionsEnumEnumMap, e)),
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'payrollAmount': 'payroll_amount',
    'payrollDate': 'payroll_date',
    'realBalanceBefore': 'real_balance_before',
    'pendingActions': 'pending_actions',
  },
);

Map<String, dynamic> _$PaydayInToJson(PaydayIn instance) => <String, dynamic>{
  'payroll_amount': instance.payrollAmount,
  'payroll_date': instance.payrollDate.toIso8601String(),
  'real_balance_before': instance.realBalanceBefore,
  'pending_actions': ?instance.pendingActions?.map(
    (k, e) => MapEntry(k, _$PaydayInPendingActionsEnumEnumMap[e]!),
  ),
};

const _$PaydayInPendingActionsEnumEnumMap = {
  PaydayInPendingActionsEnum.carry: 'carry',
  PaydayInPendingActionsEnum.cancel: 'cancel',
};
