// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetWorthOut _$NetWorthOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'NetWorthOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'total',
        'accounts',
        'investments',
        'pending',
        'by_type',
        'receivable',
        'debts',
        'installments',
        'unrealized_gain',
        'tax_if_sold',
        'after_tax',
        'tax_year',
        'tax_source',
      ],
    );
    final val = NetWorthOut(
      total: $checkedConvert('total', (v) => v as String),
      accounts: $checkedConvert(
        'accounts',
        (v) => (v as List<dynamic>)
            .map((e) => AccountBalanceOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      investments: $checkedConvert('investments', (v) => v as String),
      pending: $checkedConvert('pending', (v) => v as String),
      byType: $checkedConvert(
        'by_type',
        (v) => Map<String, String>.from(v as Map),
      ),
      receivable: $checkedConvert('receivable', (v) => v as String),
      debts: $checkedConvert('debts', (v) => v as String),
      installments: $checkedConvert('installments', (v) => v as String),
      unrealizedGain: $checkedConvert('unrealized_gain', (v) => v as String),
      taxIfSold: $checkedConvert('tax_if_sold', (v) => v as String?),
      afterTax: $checkedConvert('after_tax', (v) => v as String?),
      taxYear: $checkedConvert('tax_year', (v) => (v as num?)?.toInt()),
      taxSource: $checkedConvert('tax_source', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'byType': 'by_type',
    'unrealizedGain': 'unrealized_gain',
    'taxIfSold': 'tax_if_sold',
    'afterTax': 'after_tax',
    'taxYear': 'tax_year',
    'taxSource': 'tax_source',
  },
);

Map<String, dynamic> _$NetWorthOutToJson(NetWorthOut instance) =>
    <String, dynamic>{
      'total': instance.total,
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
      'investments': instance.investments,
      'pending': instance.pending,
      'by_type': instance.byType,
      'receivable': instance.receivable,
      'debts': instance.debts,
      'installments': instance.installments,
      'unrealized_gain': instance.unrealizedGain,
      'tax_if_sold': instance.taxIfSold,
      'after_tax': instance.afterTax,
      'tax_year': instance.taxYear,
      'tax_source': instance.taxSource,
    };
