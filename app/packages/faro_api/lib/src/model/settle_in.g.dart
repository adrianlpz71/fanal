// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settle_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettleIn _$SettleInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SettleIn',
  json,
  ($checkedConvert) {
    final val = SettleIn(
      createMovement: $checkedConvert(
        'create_movement',
        (v) => v as bool? ?? true,
      ),
      movementId: $checkedConvert('movement_id', (v) => v as String?),
      date: $checkedConvert(
        'date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'createMovement': 'create_movement',
    'movementId': 'movement_id',
  },
);

Map<String, dynamic> _$SettleInToJson(SettleIn instance) => <String, dynamic>{
  'create_movement': ?instance.createMovement,
  'movement_id': ?instance.movementId,
  'date': ?instance.date?.toIso8601String(),
};
