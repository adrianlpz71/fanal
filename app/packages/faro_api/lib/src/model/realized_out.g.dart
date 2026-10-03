// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realized_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealizedOut _$RealizedOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RealizedOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'date',
          'units',
          'proceeds',
          'gain_fifo',
          'gain_pmp',
        ],
      );
      final val = RealizedOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        units: $checkedConvert('units', (v) => v as String),
        proceeds: $checkedConvert('proceeds', (v) => v as String),
        gainFifo: $checkedConvert('gain_fifo', (v) => v as String),
        gainPmp: $checkedConvert('gain_pmp', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'gainFifo': 'gain_fifo', 'gainPmp': 'gain_pmp'});

Map<String, dynamic> _$RealizedOutToJson(RealizedOut instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'units': instance.units,
      'proceeds': instance.proceeds,
      'gain_fifo': instance.gainFifo,
      'gain_pmp': instance.gainPmp,
    };
