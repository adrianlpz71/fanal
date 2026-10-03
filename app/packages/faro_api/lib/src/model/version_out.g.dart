// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionOut _$VersionOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VersionOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['api_version', 'app']);
      final val = VersionOut(
        apiVersion: $checkedConvert('api_version', (v) => v as String),
        app: $checkedConvert(
          'app',
          (v) =>
              v == null ? null : AppRelease.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'apiVersion': 'api_version'});

Map<String, dynamic> _$VersionOutToJson(VersionOut instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'app': instance.app?.toJson(),
    };
