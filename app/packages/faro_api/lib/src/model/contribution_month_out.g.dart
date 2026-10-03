// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_month_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionMonthOut _$ContributionMonthOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ContributionMonthOut', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['year', 'month', 'total', 'by_destination'],
  );
  final val = ContributionMonthOut(
    year: $checkedConvert('year', (v) => (v as num).toInt()),
    month: $checkedConvert('month', (v) => (v as num).toInt()),
    total: $checkedConvert('total', (v) => v as String),
    byDestination: $checkedConvert(
      'by_destination',
      (v) => Map<String, String>.from(v as Map),
    ),
  );
  return val;
}, fieldKeyMap: const {'byDestination': 'by_destination'});

Map<String, dynamic> _$ContributionMonthOutToJson(
  ContributionMonthOut instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'total': instance.total,
  'by_destination': instance.byDestination,
};
