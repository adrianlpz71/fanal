// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_plan_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallmentPlanPatch _$InstallmentPlanPatchFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('InstallmentPlanPatch', json, ($checkedConvert) {
  final val = InstallmentPlanPatch(
    description: $checkedConvert('description', (v) => v as String?),
    merchant: $checkedConvert('merchant', (v) => v as String?),
    categoryId: $checkedConvert('category_id', (v) => v as String?),
    notes: $checkedConvert('notes', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'categoryId': 'category_id'});

Map<String, dynamic> _$InstallmentPlanPatchToJson(
  InstallmentPlanPatch instance,
) => <String, dynamic>{
  'description': ?instance.description,
  'merchant': ?instance.merchant,
  'category_id': ?instance.categoryId,
  'notes': ?instance.notes,
};
