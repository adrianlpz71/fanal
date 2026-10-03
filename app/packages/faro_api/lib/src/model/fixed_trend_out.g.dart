// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_trend_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedTrendOut _$FixedTrendOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FixedTrendOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['label', 'fixed']);
      final val = FixedTrendOut(
        label: $checkedConvert('label', (v) => v as String),
        fixed: $checkedConvert('fixed', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$FixedTrendOutToJson(FixedTrendOut instance) =>
    <String, dynamic>{'label': instance.label, 'fixed': instance.fixed};
