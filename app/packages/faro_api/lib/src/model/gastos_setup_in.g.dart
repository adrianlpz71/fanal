// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastos_setup_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GastosSetupIn _$GastosSetupInFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GastosSetupIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['bank', 'current_balance']);
    final val = GastosSetupIn(
      bank: $checkedConvert('bank', (v) => v as String),
      currentBalance: $checkedConvert('current_balance', (v) => v as String),
      paydayDay: $checkedConvert(
        'payday_day',
        (v) => (v as num?)?.toInt() ?? 27,
      ),
      usualPayroll: $checkedConvert('usual_payroll', (v) => v as String?),
      refugioBank: $checkedConvert('refugio_bank', (v) => v as String?),
      refugioBalance: $checkedConvert('refugio_balance', (v) => v as String?),
      emergencyTarget: $checkedConvert('emergency_target', (v) => v as String?),
      monthlyRefugio: $checkedConvert('monthly_refugio', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'currentBalance': 'current_balance',
    'paydayDay': 'payday_day',
    'usualPayroll': 'usual_payroll',
    'refugioBank': 'refugio_bank',
    'refugioBalance': 'refugio_balance',
    'emergencyTarget': 'emergency_target',
    'monthlyRefugio': 'monthly_refugio',
  },
);

Map<String, dynamic> _$GastosSetupInToJson(GastosSetupIn instance) =>
    <String, dynamic>{
      'bank': instance.bank,
      'current_balance': instance.currentBalance,
      'payday_day': ?instance.paydayDay,
      'usual_payroll': ?instance.usualPayroll,
      'refugio_bank': ?instance.refugioBank,
      'refugio_balance': ?instance.refugioBalance,
      'emergency_target': ?instance.emergencyTarget,
      'monthly_refugio': ?instance.monthlyRefugio,
    };
