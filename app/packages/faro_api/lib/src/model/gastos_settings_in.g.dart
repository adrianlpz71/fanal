// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastos_settings_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GastosSettingsIn _$GastosSettingsInFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GastosSettingsIn',
  json,
  ($checkedConvert) {
    final val = GastosSettingsIn(
      paydayDay: $checkedConvert('payday_day', (v) => (v as num?)?.toInt()),
      usualPayroll: $checkedConvert('usual_payroll', (v) => v as String?),
      emergencyTarget: $checkedConvert('emergency_target', (v) => v as String?),
      monthlyRefugio: $checkedConvert('monthly_refugio', (v) => v as String?),
      forecastMonths: $checkedConvert(
        'forecast_months',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'paydayDay': 'payday_day',
    'usualPayroll': 'usual_payroll',
    'emergencyTarget': 'emergency_target',
    'monthlyRefugio': 'monthly_refugio',
    'forecastMonths': 'forecast_months',
  },
);

Map<String, dynamic> _$GastosSettingsInToJson(GastosSettingsIn instance) =>
    <String, dynamic>{
      'payday_day': ?instance.paydayDay,
      'usual_payroll': ?instance.usualPayroll,
      'emergency_target': ?instance.emergencyTarget,
      'monthly_refugio': ?instance.monthlyRefugio,
      'forecast_months': ?instance.forecastMonths,
    };
