// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'targets_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetsIn _$TargetsInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TargetsIn', json, ($checkedConvert) {
      final val = TargetsIn(
        macro: $checkedConvert(
          'macro',
          (v) => (v as List<dynamic>?)
              ?.map((e) => MacroTargetIn.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        assets: $checkedConvert(
          'assets',
          (v) => (v as List<dynamic>?)
              ?.map((e) => AssetTargetIn.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        validFrom: $checkedConvert(
          'valid_from',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'validFrom': 'valid_from'});

Map<String, dynamic> _$TargetsInToJson(TargetsIn instance) => <String, dynamic>{
  'macro': ?instance.macro?.map((e) => e.toJson()).toList(),
  'assets': ?instance.assets?.map((e) => e.toJson()).toList(),
  'valid_from': ?instance.validFrom?.toIso8601String(),
};
