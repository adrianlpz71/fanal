// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compound_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompoundOut _$CompoundOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CompoundOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'rows',
        'total',
        'contributed',
        'interest',
        'real_total',
        'tax_if_withdrawn',
        'net_if_withdrawn',
        'convention_note',
      ],
    );
    final val = CompoundOut(
      rows: $checkedConvert(
        'rows',
        (v) => (v as List<dynamic>)
            .map((e) => CompoundYearOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      total: $checkedConvert('total', (v) => v as String),
      contributed: $checkedConvert('contributed', (v) => v as String),
      interest: $checkedConvert('interest', (v) => v as String),
      realTotal: $checkedConvert('real_total', (v) => v as String),
      taxIfWithdrawn: $checkedConvert('tax_if_withdrawn', (v) => v as String?),
      netIfWithdrawn: $checkedConvert('net_if_withdrawn', (v) => v as String?),
      conventionNote: $checkedConvert('convention_note', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'realTotal': 'real_total',
    'taxIfWithdrawn': 'tax_if_withdrawn',
    'netIfWithdrawn': 'net_if_withdrawn',
    'conventionNote': 'convention_note',
  },
);

Map<String, dynamic> _$CompoundOutToJson(CompoundOut instance) =>
    <String, dynamic>{
      'rows': instance.rows.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'contributed': instance.contributed,
      'interest': instance.interest,
      'real_total': instance.realTotal,
      'tax_if_withdrawn': instance.taxIfWithdrawn,
      'net_if_withdrawn': instance.netIfWithdrawn,
      'convention_note': instance.conventionNote,
    };
