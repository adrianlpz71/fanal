// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareIn _$ShareInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ShareIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['amount']);
    final val = ShareIn(
      personId: $checkedConvert('person_id', (v) => v as String?),
      personName: $checkedConvert('person_name', (v) => v as String?),
      amount: $checkedConvert('amount', (v) => v as String),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecodeNullable(_$ShareInDirectionEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'personId': 'person_id', 'personName': 'person_name'},
);

Map<String, dynamic> _$ShareInToJson(ShareIn instance) => <String, dynamic>{
  'person_id': ?instance.personId,
  'person_name': ?instance.personName,
  'amount': instance.amount,
  'direction': ?_$ShareInDirectionEnumEnumMap[instance.direction],
};

const _$ShareInDirectionEnumEnumMap = {
  ShareInDirectionEnum.meDeben: 'me_deben',
  ShareInDirectionEnum.debo: 'debo',
};
