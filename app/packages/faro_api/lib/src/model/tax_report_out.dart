//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/year_end_out.dart';
import 'package:faro_api/src/model/sale_out.dart';
import 'package:faro_api/src/model/income_out.dart';
import 'package:faro_api/src/model/transfer_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tax_report_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaxReportOut {
  /// Returns a new [TaxReportOut] instance.
  TaxReportOut({

    required  this.year,

    required  this.sales,

    required  this.gainsTotal,

    required  this.transfers,

    required  this.income,

    required  this.incomeTotal,

    required  this.savingsBase,

    required  this.yearEnd,

    required  this.foreignTotal,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



  @JsonKey(
    
    name: r'sales',
    required: true,
    includeIfNull: false,
  )


  final List<SaleOut> sales;



  @JsonKey(
    
    name: r'gains_total',
    required: true,
    includeIfNull: false,
  )


  final String gainsTotal;



  @JsonKey(
    
    name: r'transfers',
    required: true,
    includeIfNull: false,
  )


  final List<TransferOut> transfers;



  @JsonKey(
    
    name: r'income',
    required: true,
    includeIfNull: false,
  )


  final List<IncomeOut> income;



  @JsonKey(
    
    name: r'income_total',
    required: true,
    includeIfNull: false,
  )


  final String incomeTotal;



  @JsonKey(
    
    name: r'savings_base',
    required: true,
    includeIfNull: false,
  )


  final String savingsBase;



  @JsonKey(
    
    name: r'year_end',
    required: true,
    includeIfNull: false,
  )


  final List<YearEndOut> yearEnd;



  @JsonKey(
    
    name: r'foreign_total',
    required: true,
    includeIfNull: false,
  )


  final String foreignTotal;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaxReportOut &&
      other.year == year &&
      other.sales == sales &&
      other.gainsTotal == gainsTotal &&
      other.transfers == transfers &&
      other.income == income &&
      other.incomeTotal == incomeTotal &&
      other.savingsBase == savingsBase &&
      other.yearEnd == yearEnd &&
      other.foreignTotal == foreignTotal;

    @override
    int get hashCode =>
        year.hashCode +
        sales.hashCode +
        gainsTotal.hashCode +
        transfers.hashCode +
        income.hashCode +
        incomeTotal.hashCode +
        savingsBase.hashCode +
        yearEnd.hashCode +
        foreignTotal.hashCode;

  factory TaxReportOut.fromJson(Map<String, dynamic> json) => _$TaxReportOutFromJson(json);

  Map<String, dynamic> toJson() => _$TaxReportOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

