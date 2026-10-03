// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_plan_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallmentPlanOut _$InstallmentPlanOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'InstallmentPlanOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'description',
        'merchant',
        'provider',
        'total',
        'n',
        'every_months',
        'first_due',
        'fee',
        'status',
        'category_id',
        'paid',
        'remaining_amount',
        'next_due',
        'installments',
      ],
    );
    final val = InstallmentPlanOut(
      id: $checkedConvert('id', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String),
      merchant: $checkedConvert('merchant', (v) => v as String),
      provider: $checkedConvert(
        'provider',
        (v) => $enumDecode(_$InstallmentPlanOutProviderEnumEnumMap, v),
      ),
      total: $checkedConvert('total', (v) => v as String),
      n: $checkedConvert('n', (v) => (v as num).toInt()),
      everyMonths: $checkedConvert('every_months', (v) => (v as num).toInt()),
      firstDue: $checkedConvert(
        'first_due',
        (v) => DateTime.parse(v as String),
      ),
      fee: $checkedConvert('fee', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      paid: $checkedConvert('paid', (v) => (v as num).toInt()),
      remainingAmount: $checkedConvert('remaining_amount', (v) => v as String),
      nextDue: $checkedConvert(
        'next_due',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      installments: $checkedConvert(
        'installments',
        (v) => (v as List<dynamic>)
            .map((e) => InstallmentOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'everyMonths': 'every_months',
    'firstDue': 'first_due',
    'categoryId': 'category_id',
    'remainingAmount': 'remaining_amount',
    'nextDue': 'next_due',
  },
);

Map<String, dynamic> _$InstallmentPlanOutToJson(InstallmentPlanOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'merchant': instance.merchant,
      'provider': _$InstallmentPlanOutProviderEnumEnumMap[instance.provider]!,
      'total': instance.total,
      'n': instance.n,
      'every_months': instance.everyMonths,
      'first_due': instance.firstDue.toIso8601String(),
      'fee': instance.fee,
      'status': instance.status,
      'category_id': instance.categoryId,
      'paid': instance.paid,
      'remaining_amount': instance.remainingAmount,
      'next_due': instance.nextDue?.toIso8601String(),
      'installments': instance.installments.map((e) => e.toJson()).toList(),
    };

const _$InstallmentPlanOutProviderEnumEnumMap = {
  InstallmentPlanOutProviderEnum.paypal: 'paypal',
  InstallmentPlanOutProviderEnum.klarna: 'klarna',
  InstallmentPlanOutProviderEnum.tarjeta: 'tarjeta',
  InstallmentPlanOutProviderEnum.amazon: 'amazon',
  InstallmentPlanOutProviderEnum.eci: 'eci',
  InstallmentPlanOutProviderEnum.otro: 'otro',
};
