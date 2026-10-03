//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tax_prefill_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaxPrefillOut {
  /// Returns a new [TaxPrefillOut] instance.
  TaxPrefillOut({

    required  this.year,

    required  this.payrollNet,

    required  this.baseGeneral,

    required  this.realizedGains,

    required  this.income,

    required  this.baseSavings,

    required  this.sales,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



      /// Nóminas cobradas en el año, de los ciclos (referencia)
  @JsonKey(
    
    name: r'payroll_net',
    required: true,
    includeIfNull: false,
  )


  final String payrollNet;



  @JsonKey(
    
    name: r'base_general',
    required: true,
    includeIfNull: true,
  )


  final String? baseGeneral;



  @JsonKey(
    
    name: r'realized_gains',
    required: true,
    includeIfNull: false,
  )


  final String realizedGains;



  @JsonKey(
    
    name: r'income',
    required: true,
    includeIfNull: false,
  )


  final String income;



  @JsonKey(
    
    name: r'base_savings',
    required: true,
    includeIfNull: false,
  )


  final String baseSavings;



  @JsonKey(
    
    name: r'sales',
    required: true,
    includeIfNull: false,
  )


  final int sales;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaxPrefillOut &&
      other.year == year &&
      other.payrollNet == payrollNet &&
      other.baseGeneral == baseGeneral &&
      other.realizedGains == realizedGains &&
      other.income == income &&
      other.baseSavings == baseSavings &&
      other.sales == sales;

    @override
    int get hashCode =>
        year.hashCode +
        payrollNet.hashCode +
        (baseGeneral == null ? 0 : baseGeneral.hashCode) +
        realizedGains.hashCode +
        income.hashCode +
        baseSavings.hashCode +
        sales.hashCode;

  factory TaxPrefillOut.fromJson(Map<String, dynamic> json) => _$TaxPrefillOutFromJson(json);

  Map<String, dynamic> toJson() => _$TaxPrefillOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

