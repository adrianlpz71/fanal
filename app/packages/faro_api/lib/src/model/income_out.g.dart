// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeOut _$IncomeOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'IncomeOut',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['source', 'date', 'amount', 'kind']);
    final val = IncomeOut(
      source_: $checkedConvert('source', (v) => v as String),
      date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
      amount: $checkedConvert('amount', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$IncomeOutKindEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'source_': 'source'},
);

Map<String, dynamic> _$IncomeOutToJson(IncomeOut instance) => <String, dynamic>{
  'source': instance.source_,
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
  'kind': _$IncomeOutKindEnumEnumMap[instance.kind]!,
};

const _$IncomeOutKindEnumEnumMap = {
  IncomeOutKindEnum.interesCuenta: 'interes_cuenta',
  IncomeOutKindEnum.dividendo: 'dividendo',
  IncomeOutKindEnum.interes: 'interes',
  IncomeOutKindEnum.recompensaCripto: 'recompensa_cripto',
};
