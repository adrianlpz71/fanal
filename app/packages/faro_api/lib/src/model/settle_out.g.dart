// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settle_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettleOut _$SettleOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SettleOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['share', 'movement_id']);
      final val = SettleOut(
        share: $checkedConvert(
          'share',
          (v) => ShareOut.fromJson(v as Map<String, dynamic>),
        ),
        movementId: $checkedConvert('movement_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'movementId': 'movement_id'});

Map<String, dynamic> _$SettleOutToJson(SettleOut instance) => <String, dynamic>{
  'share': instance.share.toJson(),
  'movement_id': instance.movementId,
};
