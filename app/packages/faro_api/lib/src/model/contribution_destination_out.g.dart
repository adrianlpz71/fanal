// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_destination_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionDestinationOut _$ContributionDestinationOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ContributionDestinationOut', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['key', 'label', 'kind']);
  final val = ContributionDestinationOut(
    key: $checkedConvert('key', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$ContributionDestinationOutKindEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ContributionDestinationOutToJson(
  ContributionDestinationOut instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'kind': _$ContributionDestinationOutKindEnumEnumMap[instance.kind]!,
};

const _$ContributionDestinationOutKindEnumEnumMap = {
  ContributionDestinationOutKindEnum.inversion: 'inversion',
  ContributionDestinationOutKindEnum.ahorro: 'ahorro',
};
