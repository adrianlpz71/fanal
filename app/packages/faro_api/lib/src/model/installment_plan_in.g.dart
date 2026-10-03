// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_plan_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallmentPlanIn _$InstallmentPlanInFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'InstallmentPlanIn',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['description', 'total', 'n', 'first_due'],
        );
        final val = InstallmentPlanIn(
          description: $checkedConvert('description', (v) => v as String),
          merchant: $checkedConvert('merchant', (v) => v as String? ?? ''),
          provider: $checkedConvert(
            'provider',
            (v) =>
                $enumDecodeNullable(_$InstallmentPlanInProviderEnumEnumMap, v),
          ),
          total: $checkedConvert('total', (v) => v as String),
          n: $checkedConvert('n', (v) => (v as num).toInt()),
          firstDue: $checkedConvert(
            'first_due',
            (v) => DateTime.parse(v as String),
          ),
          everyMonths: $checkedConvert(
            'every_months',
            (v) => (v as num?)?.toInt() ?? 1,
          ),
          fee: $checkedConvert('fee', (v) => v as String? ?? '0'),
          categoryId: $checkedConvert('category_id', (v) => v as String?),
          customAmounts: $checkedConvert(
            'custom_amounts',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          paidCount: $checkedConvert(
            'paid_count',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'firstDue': 'first_due',
        'everyMonths': 'every_months',
        'categoryId': 'category_id',
        'customAmounts': 'custom_amounts',
        'paidCount': 'paid_count',
      },
    );

Map<String, dynamic> _$InstallmentPlanInToJson(InstallmentPlanIn instance) =>
    <String, dynamic>{
      'description': instance.description,
      'merchant': ?instance.merchant,
      'provider': ?_$InstallmentPlanInProviderEnumEnumMap[instance.provider],
      'total': instance.total,
      'n': instance.n,
      'first_due': instance.firstDue.toIso8601String(),
      'every_months': ?instance.everyMonths,
      'fee': ?instance.fee,
      'category_id': ?instance.categoryId,
      'custom_amounts': ?instance.customAmounts,
      'paid_count': ?instance.paidCount,
    };

const _$InstallmentPlanInProviderEnumEnumMap = {
  InstallmentPlanInProviderEnum.paypal: 'paypal',
  InstallmentPlanInProviderEnum.klarna: 'klarna',
  InstallmentPlanInProviderEnum.tarjeta: 'tarjeta',
  InstallmentPlanInProviderEnum.amazon: 'amazon',
  InstallmentPlanInProviderEnum.eci: 'eci',
  InstallmentPlanInProviderEnum.otro: 'otro',
};
