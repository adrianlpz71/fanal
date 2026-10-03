// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_point_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetWorthPointOut _$NetWorthPointOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NetWorthPointOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'accounts', 'investments']);
      final val = NetWorthPointOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        accounts: $checkedConvert('accounts', (v) => v as String),
        investments: $checkedConvert('investments', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$NetWorthPointOutToJson(NetWorthPointOut instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'accounts': instance.accounts,
      'investments': instance.investments,
    };
