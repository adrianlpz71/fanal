// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_profile_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankProfileOut _$BankProfileOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BankProfileOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'mapping']);
      final val = BankProfileOut(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        mapping: $checkedConvert(
          'mapping',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BankProfileOutToJson(BankProfileOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mapping': instance.mapping,
    };
