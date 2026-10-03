// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchOut _$BatchOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'BatchOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'kind',
        'filename',
        'status',
        'created_at',
        'counts',
        'file_balance',
      ],
    );
    final val = BatchOut(
      id: $checkedConvert('id', (v) => v as String),
      kind: $checkedConvert('kind', (v) => v as String),
      filename: $checkedConvert('filename', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      counts: $checkedConvert('counts', (v) => Map<String, int>.from(v as Map)),
      fileBalance: $checkedConvert('file_balance', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'createdAt': 'created_at', 'fileBalance': 'file_balance'},
);

Map<String, dynamic> _$BatchOutToJson(BatchOut instance) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'filename': instance.filename,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'counts': instance.counts,
  'file_balance': instance.fileBalance,
};
