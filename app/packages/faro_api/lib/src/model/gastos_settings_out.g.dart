// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastos_settings_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GastosSettingsOut _$GastosSettingsOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GastosSettingsOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'configured',
        'payday_day',
        'usual_payroll',
        'main_account_id',
        'refugio_account_id',
        'emergency_target',
        'monthly_refugio',
        'forecast_months',
      ],
    );
    final val = GastosSettingsOut(
      configured: $checkedConvert('configured', (v) => v as bool),
      paydayDay: $checkedConvert('payday_day', (v) => (v as num).toInt()),
      usualPayroll: $checkedConvert('usual_payroll', (v) => v as String?),
      mainAccountId: $checkedConvert('main_account_id', (v) => v as String?),
      refugioAccountId: $checkedConvert(
        'refugio_account_id',
        (v) => v as String?,
      ),
      emergencyTarget: $checkedConvert('emergency_target', (v) => v as String?),
      monthlyRefugio: $checkedConvert('monthly_refugio', (v) => v as String?),
      forecastMonths: $checkedConvert(
        'forecast_months',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'paydayDay': 'payday_day',
    'usualPayroll': 'usual_payroll',
    'mainAccountId': 'main_account_id',
    'refugioAccountId': 'refugio_account_id',
    'emergencyTarget': 'emergency_target',
    'monthlyRefugio': 'monthly_refugio',
    'forecastMonths': 'forecast_months',
  },
);

Map<String, dynamic> _$GastosSettingsOutToJson(GastosSettingsOut instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'payday_day': instance.paydayDay,
      'usual_payroll': instance.usualPayroll,
      'main_account_id': instance.mainAccountId,
      'refugio_account_id': instance.refugioAccountId,
      'emergency_target': instance.emergencyTarget,
      'monthly_refugio': instance.monthlyRefugio,
      'forecast_months': instance.forecastMonths,
    };
