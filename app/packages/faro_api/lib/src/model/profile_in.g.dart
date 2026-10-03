// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileIn _$ProfileInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ProfileIn',
  json,
  ($checkedConvert) {
    final val = ProfileIn(
      displayName: $checkedConvert('display_name', (v) => v as String?),
      birthDate: $checkedConvert(
        'birth_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      taxRegion: $checkedConvert('tax_region', (v) => v as String?),
      completeOnboarding: $checkedConvert(
        'complete_onboarding',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'birthDate': 'birth_date',
    'taxRegion': 'tax_region',
    'completeOnboarding': 'complete_onboarding',
  },
);

Map<String, dynamic> _$ProfileInToJson(ProfileIn instance) => <String, dynamic>{
  'display_name': ?instance.displayName,
  'birth_date': ?instance.birthDate?.toIso8601String(),
  'tax_region': ?instance.taxRegion,
  'complete_onboarding': ?instance.completeOnboarding,
};
