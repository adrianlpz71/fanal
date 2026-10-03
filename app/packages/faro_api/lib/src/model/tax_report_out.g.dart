// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_report_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxReportOut _$TaxReportOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TaxReportOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'year',
            'sales',
            'gains_total',
            'transfers',
            'income',
            'income_total',
            'savings_base',
            'year_end',
            'foreign_total',
          ],
        );
        final val = TaxReportOut(
          year: $checkedConvert('year', (v) => (v as num).toInt()),
          sales: $checkedConvert(
            'sales',
            (v) => (v as List<dynamic>)
                .map((e) => SaleOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          gainsTotal: $checkedConvert('gains_total', (v) => v as String),
          transfers: $checkedConvert(
            'transfers',
            (v) => (v as List<dynamic>)
                .map((e) => TransferOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          income: $checkedConvert(
            'income',
            (v) => (v as List<dynamic>)
                .map((e) => IncomeOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          incomeTotal: $checkedConvert('income_total', (v) => v as String),
          savingsBase: $checkedConvert('savings_base', (v) => v as String),
          yearEnd: $checkedConvert(
            'year_end',
            (v) => (v as List<dynamic>)
                .map((e) => YearEndOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          foreignTotal: $checkedConvert('foreign_total', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'gainsTotal': 'gains_total',
        'incomeTotal': 'income_total',
        'savingsBase': 'savings_base',
        'yearEnd': 'year_end',
        'foreignTotal': 'foreign_total',
      },
    );

Map<String, dynamic> _$TaxReportOutToJson(TaxReportOut instance) =>
    <String, dynamic>{
      'year': instance.year,
      'sales': instance.sales.map((e) => e.toJson()).toList(),
      'gains_total': instance.gainsTotal,
      'transfers': instance.transfers.map((e) => e.toJson()).toList(),
      'income': instance.income.map((e) => e.toJson()).toList(),
      'income_total': instance.incomeTotal,
      'savings_base': instance.savingsBase,
      'year_end': instance.yearEnd.map((e) => e.toJson()).toList(),
      'foreign_total': instance.foreignTotal,
    };
