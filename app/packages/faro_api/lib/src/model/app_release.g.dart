// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppRelease _$AppReleaseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AppRelease',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['version', 'build', 'apk_url']);
    final val = AppRelease(
      version: $checkedConvert('version', (v) => v as String),
      build: $checkedConvert('build', (v) => (v as num).toInt()),
      apkUrl: $checkedConvert('apk_url', (v) => v as String),
      sha256: $checkedConvert('sha256', (v) => v as String?),
      minSupportedBuild: $checkedConvert(
        'min_supported_build',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'apkUrl': 'apk_url',
    'minSupportedBuild': 'min_supported_build',
  },
);

Map<String, dynamic> _$AppReleaseToJson(AppRelease instance) =>
    <String, dynamic>{
      'version': instance.version,
      'build': instance.build,
      'apk_url': instance.apkUrl,
      'sha256': ?instance.sha256,
      'min_supported_build': ?instance.minSupportedBuild,
      'notes': ?instance.notes,
    };
