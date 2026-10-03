// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_result_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobResultOut _$JobResultOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JobResultOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['updated', 'errors']);
      final val = JobResultOut(
        updated: $checkedConvert('updated', (v) => (v as num).toInt()),
        errors: $checkedConvert(
          'errors',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$JobResultOutToJson(JobResultOut instance) =>
    <String, dynamic>{'updated': instance.updated, 'errors': instance.errors};
