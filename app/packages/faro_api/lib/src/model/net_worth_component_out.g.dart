// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_component_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetWorthComponentOut _$NetWorthComponentOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NetWorthComponentOut', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['key', 'label', 'kind', 'group', 'entity'],
  );
  final val = NetWorthComponentOut(
    key: $checkedConvert('key', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$NetWorthComponentOutKindEnumEnumMap, v),
    ),
    group: $checkedConvert('group', (v) => v as String),
    entity: $checkedConvert('entity', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$NetWorthComponentOutToJson(
  NetWorthComponentOut instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'kind': _$NetWorthComponentOutKindEnumEnumMap[instance.kind]!,
  'group': instance.group,
  'entity': instance.entity,
};

const _$NetWorthComponentOutKindEnumEnumMap = {
  NetWorthComponentOutKindEnum.cuenta: 'cuenta',
  NetWorthComponentOutKindEnum.inversion: 'inversion',
};
