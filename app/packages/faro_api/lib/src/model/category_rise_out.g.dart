// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_rise_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryRiseOut _$CategoryRiseOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryRiseOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'amount', 'previous']);
      final val = CategoryRiseOut(
        name: $checkedConvert('name', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        previous: $checkedConvert('previous', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CategoryRiseOutToJson(CategoryRiseOut instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'previous': instance.previous,
    };
