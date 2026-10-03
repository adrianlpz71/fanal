// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fire_result_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireResultOut _$FireResultOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'FireResultOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'real_return',
            'needed',
            'needed_nominal',
            'progress',
            'required_monthly',
            'fi_age',
            'coast',
            'coast_reached',
            'bridge',
          ],
        );
        final val = FireResultOut(
          realReturn: $checkedConvert('real_return', (v) => v as String),
          needed: $checkedConvert('needed', (v) => v as String),
          neededNominal: $checkedConvert('needed_nominal', (v) => v as String),
          progress: $checkedConvert('progress', (v) => v as String),
          requiredMonthly: $checkedConvert(
            'required_monthly',
            (v) => v as String,
          ),
          fiAge: $checkedConvert('fi_age', (v) => v as String?),
          coast: $checkedConvert('coast', (v) => v as String),
          coastReached: $checkedConvert('coast_reached', (v) => v as bool),
          bridge: $checkedConvert('bridge', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'realReturn': 'real_return',
        'neededNominal': 'needed_nominal',
        'requiredMonthly': 'required_monthly',
        'fiAge': 'fi_age',
        'coastReached': 'coast_reached',
      },
    );

Map<String, dynamic> _$FireResultOutToJson(FireResultOut instance) =>
    <String, dynamic>{
      'real_return': instance.realReturn,
      'needed': instance.needed,
      'needed_nominal': instance.neededNominal,
      'progress': instance.progress,
      'required_monthly': instance.requiredMonthly,
      'fi_age': instance.fiAge,
      'coast': instance.coast,
      'coast_reached': instance.coastReached,
      'bridge': instance.bridge,
    };
