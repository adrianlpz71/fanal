// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_point_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesPointOut _$SeriesPointOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SeriesPointOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'value', 'contributed']);
      final val = SeriesPointOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        value: $checkedConvert('value', (v) => v as String),
        contributed: $checkedConvert('contributed', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SeriesPointOutToJson(SeriesPointOut instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'contributed': instance.contributed,
    };
