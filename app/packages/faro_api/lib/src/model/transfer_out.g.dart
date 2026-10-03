// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferOut _$TransferOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TransferOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['asset', 'date', 'units']);
      final val = TransferOut(
        asset: $checkedConvert('asset', (v) => v as String),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        units: $checkedConvert('units', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TransferOutToJson(TransferOut instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'date': instance.date.toIso8601String(),
      'units': instance.units,
    };
