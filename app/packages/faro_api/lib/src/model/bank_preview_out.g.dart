// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_preview_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankPreviewOut _$BankPreviewOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'BankPreviewOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'headers',
        'mapping',
        'counts',
        'errors',
        'lines',
        'file_balance',
        'balance_after',
      ],
    );
    final val = BankPreviewOut(
      headers: $checkedConvert(
        'headers',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      mapping: $checkedConvert(
        'mapping',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      counts: $checkedConvert('counts', (v) => Map<String, int>.from(v as Map)),
      errors: $checkedConvert(
        'errors',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => BankLineOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      fileBalance: $checkedConvert('file_balance', (v) => v as String?),
      balanceAfter: $checkedConvert('balance_after', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'fileBalance': 'file_balance',
    'balanceAfter': 'balance_after',
  },
);

Map<String, dynamic> _$BankPreviewOutToJson(BankPreviewOut instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'mapping': instance.mapping,
      'counts': instance.counts,
      'errors': instance.errors,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'file_balance': instance.fileBalance,
      'balance_after': instance.balanceAfter,
    };
