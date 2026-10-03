// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_batch_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformBatchOut _$PlatformBatchOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlatformBatchOut', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'filename', 'status', 'counts']);
  final val = PlatformBatchOut(
    id: $checkedConvert('id', (v) => v as String),
    filename: $checkedConvert('filename', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    counts: $checkedConvert('counts', (v) => Map<String, int>.from(v as Map)),
  );
  return val;
});

Map<String, dynamic> _$PlatformBatchOutToJson(PlatformBatchOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'status': instance.status,
      'counts': instance.counts,
    };
