// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_profile_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankProfileIn _$BankProfileInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BankProfileIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'mapping']);
      final val = BankProfileIn(
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

Map<String, dynamic> _$BankProfileInToJson(BankProfileIn instance) =>
    <String, dynamic>{'name': instance.name, 'mapping': instance.mapping};
