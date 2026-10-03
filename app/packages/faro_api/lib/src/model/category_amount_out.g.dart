// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_amount_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryAmountOut _$CategoryAmountOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryAmountOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['category_id', 'amount']);
      final val = CategoryAmountOut(
        categoryId: $checkedConvert('category_id', (v) => v as String?),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'categoryId': 'category_id'});

Map<String, dynamic> _$CategoryAmountOutToJson(CategoryAmountOut instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'amount': instance.amount,
    };
