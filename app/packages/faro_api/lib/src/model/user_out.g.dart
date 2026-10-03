// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOut _$UserOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'UserOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'email',
        'display_name',
        'birth_date',
        'locale',
        'currency',
        'timezone',
        'tax_region',
        'onboarding_completed',
      ],
    );
    final val = UserOut(
      id: $checkedConvert('id', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      displayName: $checkedConvert('display_name', (v) => v as String),
      birthDate: $checkedConvert(
        'birth_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      locale: $checkedConvert('locale', (v) => v as String),
      currency: $checkedConvert('currency', (v) => v as String),
      timezone: $checkedConvert('timezone', (v) => v as String),
      taxRegion: $checkedConvert('tax_region', (v) => v as String),
      onboardingCompleted: $checkedConvert(
        'onboarding_completed',
        (v) => v as bool,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'birthDate': 'birth_date',
    'taxRegion': 'tax_region',
    'onboardingCompleted': 'onboarding_completed',
  },
);

Map<String, dynamic> _$UserOutToJson(UserOut instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'birth_date': instance.birthDate?.toIso8601String(),
  'locale': instance.locale,
  'currency': instance.currency,
  'timezone': instance.timezone,
  'tax_region': instance.taxRegion,
  'onboarding_completed': instance.onboardingCompleted,
};
