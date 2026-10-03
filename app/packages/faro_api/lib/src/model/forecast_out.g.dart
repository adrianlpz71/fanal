// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastOut _$ForecastOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ForecastOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['months', 'live_installment_debt']);
      final val = ForecastOut(
        months: $checkedConvert(
          'months',
          (v) => (v as List<dynamic>)
              .map((e) => ForecastMonthOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        liveInstallmentDebt: $checkedConvert(
          'live_installment_debt',
          (v) => v as String,
        ),
      );
      return val;
    }, fieldKeyMap: const {'liveInstallmentDebt': 'live_installment_debt'});

Map<String, dynamic> _$ForecastOutToJson(ForecastOut instance) =>
    <String, dynamic>{
      'months': instance.months.map((e) => e.toJson()).toList(),
      'live_installment_debt': instance.liveInstallmentDebt,
    };
