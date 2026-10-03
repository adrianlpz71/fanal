// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_op_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformOpOut _$PlatformOpOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlatformOpOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'row',
          'date',
          'kind',
          'key',
          'asset_name',
          'units',
          'amount',
          'outcome',
          'note',
        ],
      );
      final val = PlatformOpOut(
        row: $checkedConvert('row', (v) => (v as num).toInt()),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PlatformOpOutKindEnumEnumMap, v),
        ),
        key: $checkedConvert('key', (v) => v as String),
        assetName: $checkedConvert('asset_name', (v) => v as String),
        units: $checkedConvert('units', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        outcome: $checkedConvert(
          'outcome',
          (v) => $enumDecode(_$PlatformOpOutOutcomeEnumEnumMap, v),
        ),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'assetName': 'asset_name'});

Map<String, dynamic> _$PlatformOpOutToJson(PlatformOpOut instance) =>
    <String, dynamic>{
      'row': instance.row,
      'date': instance.date.toIso8601String(),
      'kind': _$PlatformOpOutKindEnumEnumMap[instance.kind]!,
      'key': instance.key,
      'asset_name': instance.assetName,
      'units': instance.units,
      'amount': instance.amount,
      'outcome': _$PlatformOpOutOutcomeEnumEnumMap[instance.outcome]!,
      'note': instance.note,
    };

const _$PlatformOpOutKindEnumEnumMap = {
  PlatformOpOutKindEnum.posicionInicial: 'posicion_inicial',
  PlatformOpOutKindEnum.compra: 'compra',
  PlatformOpOutKindEnum.venta: 'venta',
  PlatformOpOutKindEnum.aportacionPeriodica: 'aportacion_periodica',
  PlatformOpOutKindEnum.traspasoSalida: 'traspaso_salida',
  PlatformOpOutKindEnum.traspasoEntrada: 'traspaso_entrada',
  PlatformOpOutKindEnum.dividendo: 'dividendo',
  PlatformOpOutKindEnum.interes: 'interes',
  PlatformOpOutKindEnum.comision: 'comision',
  PlatformOpOutKindEnum.recompensa: 'recompensa',
};

const _$PlatformOpOutOutcomeEnumEnumMap = {
  PlatformOpOutOutcomeEnum.new_: 'new',
  PlatformOpOutOutcomeEnum.duplicate: 'duplicate',
  PlatformOpOutOutcomeEnum.completePending: 'complete_pending',
};
