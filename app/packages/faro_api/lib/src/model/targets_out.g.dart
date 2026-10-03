// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'targets_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetsOut _$TargetsOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TargetsOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['macro', 'assets']);
      final val = TargetsOut(
        macro: $checkedConvert(
          'macro',
          (v) => (v as List<dynamic>)
              .map((e) => MacroTargetOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        assets: $checkedConvert(
          'assets',
          (v) => (v as List<dynamic>)
              .map((e) => AssetTargetOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TargetsOutToJson(TargetsOut instance) =>
    <String, dynamic>{
      'macro': instance.macro.map((e) => e.toJson()).toList(),
      'assets': instance.assets.map((e) => e.toJson()).toList(),
    };
