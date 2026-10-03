// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleOut _$SaleOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SaleOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'asset',
          'date',
          'units',
          'proceeds',
          'cost',
          'gain',
        ],
      );
      final val = SaleOut(
        asset: $checkedConvert('asset', (v) => v as String),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        units: $checkedConvert('units', (v) => v as String),
        proceeds: $checkedConvert('proceeds', (v) => v as String),
        cost: $checkedConvert('cost', (v) => v as String),
        gain: $checkedConvert('gain', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SaleOutToJson(SaleOut instance) => <String, dynamic>{
  'asset': instance.asset,
  'date': instance.date.toIso8601String(),
  'units': instance.units,
  'proceeds': instance.proceeds,
  'cost': instance.cost,
  'gain': instance.gain,
};
