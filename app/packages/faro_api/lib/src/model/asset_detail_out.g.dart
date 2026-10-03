// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_detail_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetDetailOut _$AssetDetailOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssetDetailOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'position',
          'lots',
          'realized',
          'income',
          'transactions',
        ],
      );
      final val = AssetDetailOut(
        position: $checkedConvert(
          'position',
          (v) => PositionOut.fromJson(v as Map<String, dynamic>),
        ),
        lots: $checkedConvert(
          'lots',
          (v) => (v as List<dynamic>)
              .map((e) => LotOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        realized: $checkedConvert(
          'realized',
          (v) => (v as List<dynamic>)
              .map((e) => RealizedOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        income: $checkedConvert('income', (v) => v as String),
        transactions: $checkedConvert(
          'transactions',
          (v) => (v as List<dynamic>)
              .map((e) => TxOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AssetDetailOutToJson(AssetDetailOut instance) =>
    <String, dynamic>{
      'position': instance.position.toJson(),
      'lots': instance.lots.map((e) => e.toJson()).toList(),
      'realized': instance.realized.map((e) => e.toJson()).toList(),
      'income': instance.income,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
    };
