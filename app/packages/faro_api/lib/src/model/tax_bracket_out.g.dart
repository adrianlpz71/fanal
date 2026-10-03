// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_bracket_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxBracketOut _$TaxBracketOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TaxBracketOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['lo', 'hi', 'rate', 'amount', 'tax'],
      );
      final val = TaxBracketOut(
        lo: $checkedConvert('lo', (v) => v as String),
        hi: $checkedConvert('hi', (v) => v as String?),
        rate: $checkedConvert('rate', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        tax: $checkedConvert('tax', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TaxBracketOutToJson(TaxBracketOut instance) =>
    <String, dynamic>{
      'lo': instance.lo,
      'hi': instance.hi,
      'rate': instance.rate,
      'amount': instance.amount,
      'tax': instance.tax,
    };
