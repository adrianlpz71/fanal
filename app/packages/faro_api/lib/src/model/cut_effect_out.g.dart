// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_effect_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CutEffectOut _$CutEffectOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CutEffectOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['cut', 'fi_age']);
      final val = CutEffectOut(
        cut: $checkedConvert('cut', (v) => v as String),
        fiAge: $checkedConvert('fi_age', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'fiAge': 'fi_age'});

Map<String, dynamic> _$CutEffectOutToJson(CutEffectOut instance) =>
    <String, dynamic>{'cut': instance.cut, 'fi_age': instance.fiAge};
