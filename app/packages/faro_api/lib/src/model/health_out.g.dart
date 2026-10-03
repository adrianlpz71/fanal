// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthOut _$HealthOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'db', 'worker_seen']);
      final val = HealthOut(
        status: $checkedConvert('status', (v) => v as String),
        db: $checkedConvert('db', (v) => v as bool),
        workerSeen: $checkedConvert('worker_seen', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'workerSeen': 'worker_seen'});

Map<String, dynamic> _$HealthOutToJson(HealthOut instance) => <String, dynamic>{
  'status': instance.status,
  'db': instance.db,
  'worker_seen': instance.workerSeen,
};
