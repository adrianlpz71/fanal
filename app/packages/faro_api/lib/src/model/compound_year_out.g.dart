// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compound_year_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompoundYearOut _$CompoundYearOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CompoundYearOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'year',
          'contributed',
          'interest',
          'total',
          'real_total',
        ],
      );
      final val = CompoundYearOut(
        year: $checkedConvert('year', (v) => (v as num).toInt()),
        contributed: $checkedConvert('contributed', (v) => v as String),
        interest: $checkedConvert('interest', (v) => v as String),
        total: $checkedConvert('total', (v) => v as String),
        realTotal: $checkedConvert('real_total', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'realTotal': 'real_total'});

Map<String, dynamic> _$CompoundYearOutToJson(CompoundYearOut instance) =>
    <String, dynamic>{
      'year': instance.year,
      'contributed': instance.contributed,
      'interest': instance.interest,
      'total': instance.total,
      'real_total': instance.realTotal,
    };
