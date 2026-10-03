// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_item_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionItemOut _$ContributionItemOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ContributionItemOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'date',
            'type',
            'kind',
            'destination',
            'destination_label',
            'amount',
            'origin',
            'status',
            'tx_id',
            'movement_id',
            'asset_id',
            'account_id',
          ],
        );
        final val = ContributionItemOut(
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          type: $checkedConvert(
            'type',
            (v) => $enumDecode(_$ContributionItemOutTypeEnumEnumMap, v),
          ),
          kind: $checkedConvert(
            'kind',
            (v) => $enumDecode(_$ContributionItemOutKindEnumEnumMap, v),
          ),
          destination: $checkedConvert('destination', (v) => v as String),
          destinationLabel: $checkedConvert(
            'destination_label',
            (v) => v as String,
          ),
          amount: $checkedConvert('amount', (v) => v as String),
          origin: $checkedConvert('origin', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$ContributionItemOutStatusEnumEnumMap, v),
          ),
          txId: $checkedConvert('tx_id', (v) => v as String?),
          movementId: $checkedConvert('movement_id', (v) => v as String?),
          assetId: $checkedConvert('asset_id', (v) => v as String?),
          accountId: $checkedConvert('account_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'destinationLabel': 'destination_label',
        'txId': 'tx_id',
        'movementId': 'movement_id',
        'assetId': 'asset_id',
        'accountId': 'account_id',
      },
    );

Map<String, dynamic> _$ContributionItemOutToJson(
  ContributionItemOut instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'type': _$ContributionItemOutTypeEnumEnumMap[instance.type]!,
  'kind': _$ContributionItemOutKindEnumEnumMap[instance.kind]!,
  'destination': instance.destination,
  'destination_label': instance.destinationLabel,
  'amount': instance.amount,
  'origin': instance.origin,
  'status': _$ContributionItemOutStatusEnumEnumMap[instance.status]!,
  'tx_id': instance.txId,
  'movement_id': instance.movementId,
  'asset_id': instance.assetId,
  'account_id': instance.accountId,
};

const _$ContributionItemOutTypeEnumEnumMap = {
  ContributionItemOutTypeEnum.aportacion: 'aportacion',
  ContributionItemOutTypeEnum.retirada: 'retirada',
  ContributionItemOutTypeEnum.traspaso: 'traspaso',
  ContributionItemOutTypeEnum.partida: 'partida',
};

const _$ContributionItemOutKindEnumEnumMap = {
  ContributionItemOutKindEnum.inversion: 'inversion',
  ContributionItemOutKindEnum.ahorro: 'ahorro',
};

const _$ContributionItemOutStatusEnumEnumMap = {
  ContributionItemOutStatusEnum.confirmada: 'confirmada',
  ContributionItemOutStatusEnum.pendiente: 'pendiente',
};
