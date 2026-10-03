// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPatch _$AccountPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountPatch', json, ($checkedConvert) {
      final val = AccountPatch(
        name: $checkedConvert('name', (v) => v as String?),
        bank: $checkedConvert('bank', (v) => v as String?),
        archived: $checkedConvert('archived', (v) => v as bool?),
        apy: $checkedConvert('apy', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AccountPatchToJson(AccountPatch instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'bank': ?instance.bank,
      'archived': ?instance.archived,
      'apy': ?instance.apy,
    };
