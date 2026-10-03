// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reconcile_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReconcileIn _$ReconcileInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ReconcileIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['real_balance']);
    final val = ReconcileIn(
      realBalance: $checkedConvert('real_balance', (v) => v as String),
      createAdjustment: $checkedConvert(
        'create_adjustment',
        (v) => v as bool? ?? true,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'realBalance': 'real_balance',
    'createAdjustment': 'create_adjustment',
  },
);

Map<String, dynamic> _$ReconcileInToJson(ReconcileIn instance) =>
    <String, dynamic>{
      'real_balance': instance.realBalance,
      'create_adjustment': ?instance.createAdjustment,
    };
