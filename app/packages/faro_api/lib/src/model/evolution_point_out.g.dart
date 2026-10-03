// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evolution_point_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvolutionPointOut _$EvolutionPointOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EvolutionPointOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'date',
          'accounts',
          'investments',
          'contributed',
          'pending',
          'receivable',
          'debts',
          'installments',
          'net',
          'components',
        ],
      );
      final val = EvolutionPointOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        accounts: $checkedConvert('accounts', (v) => v as String),
        investments: $checkedConvert('investments', (v) => v as String),
        contributed: $checkedConvert('contributed', (v) => v as String),
        pending: $checkedConvert('pending', (v) => v as String),
        receivable: $checkedConvert('receivable', (v) => v as String),
        debts: $checkedConvert('debts', (v) => v as String),
        installments: $checkedConvert('installments', (v) => v as String),
        net: $checkedConvert('net', (v) => v as String),
        components: $checkedConvert(
          'components',
          (v) => Map<String, String>.from(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EvolutionPointOutToJson(EvolutionPointOut instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'accounts': instance.accounts,
      'investments': instance.investments,
      'contributed': instance.contributed,
      'pending': instance.pending,
      'receivable': instance.receivable,
      'debts': instance.debts,
      'installments': instance.installments,
      'net': instance.net,
      'components': instance.components,
    };
