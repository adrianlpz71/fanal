// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtPatch _$DebtPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DebtPatch', json, ($checkedConvert) {
      final val = DebtPatch(
        name: $checkedConvert('name', (v) => v as String?),
        notes: $checkedConvert('notes', (v) => v as String?),
        interestRate: $checkedConvert('interest_rate', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'interestRate': 'interest_rate'});

Map<String, dynamic> _$DebtPatchToJson(DebtPatch instance) => <String, dynamic>{
  'name': ?instance.name,
  'notes': ?instance.notes,
  'interest_rate': ?instance.interestRate,
};
