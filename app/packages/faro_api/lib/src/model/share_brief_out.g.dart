// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_brief_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareBriefOut _$ShareBriefOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShareBriefOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'person_name',
          'amount',
          'direction',
          'status',
        ],
      );
      final val = ShareBriefOut(
        id: $checkedConvert('id', (v) => v as String),
        personName: $checkedConvert('person_name', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        direction: $checkedConvert(
          'direction',
          (v) => $enumDecode(_$ShareBriefOutDirectionEnumEnumMap, v),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ShareBriefOutStatusEnumEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'personName': 'person_name'});

Map<String, dynamic> _$ShareBriefOutToJson(ShareBriefOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person_name': instance.personName,
      'amount': instance.amount,
      'direction': _$ShareBriefOutDirectionEnumEnumMap[instance.direction]!,
      'status': _$ShareBriefOutStatusEnumEnumMap[instance.status]!,
    };

const _$ShareBriefOutDirectionEnumEnumMap = {
  ShareBriefOutDirectionEnum.meDeben: 'me_deben',
  ShareBriefOutDirectionEnum.debo: 'debo',
};

const _$ShareBriefOutStatusEnumEnumMap = {
  ShareBriefOutStatusEnum.pendiente: 'pendiente',
  ShareBriefOutStatusEnum.saldada: 'saldada',
};
