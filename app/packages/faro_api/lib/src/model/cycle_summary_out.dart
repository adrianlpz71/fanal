//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'cycle_summary_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CycleSummaryOut {
  /// Returns a new [CycleSummaryOut] instance.
  CycleSummaryOut({

    required  this.carried,

    required  this.payroll,

    required  this.opening,

    required  this.availableNow,

    required  this.expectedEnd,

    required  this.netMovements,

    required  this.pendingTotal,

    required  this.fixedSpend,

    required  this.variableSpend,

    required  this.installments,

    required  this.savings,

    required  this.savingsRate,

    required  this.daysToPayday,

    required  this.perDay,
  });

  @JsonKey(
    
    name: r'carried',
    required: true,
    includeIfNull: false,
  )


  final String carried;



  @JsonKey(
    
    name: r'payroll',
    required: true,
    includeIfNull: false,
  )


  final String payroll;



  @JsonKey(
    
    name: r'opening',
    required: true,
    includeIfNull: false,
  )


  final String opening;



  @JsonKey(
    
    name: r'available_now',
    required: true,
    includeIfNull: false,
  )


  final String availableNow;



  @JsonKey(
    
    name: r'expected_end',
    required: true,
    includeIfNull: false,
  )


  final String expectedEnd;



  @JsonKey(
    
    name: r'net_movements',
    required: true,
    includeIfNull: false,
  )


  final String netMovements;



  @JsonKey(
    
    name: r'pending_total',
    required: true,
    includeIfNull: false,
  )


  final String pendingTotal;



  @JsonKey(
    
    name: r'fixed_spend',
    required: true,
    includeIfNull: false,
  )


  final String fixedSpend;



  @JsonKey(
    
    name: r'variable_spend',
    required: true,
    includeIfNull: false,
  )


  final String variableSpend;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final String installments;



  @JsonKey(
    
    name: r'savings',
    required: true,
    includeIfNull: false,
  )


  final String savings;



  @JsonKey(
    
    name: r'savings_rate',
    required: true,
    includeIfNull: true,
  )


  final String? savingsRate;



  @JsonKey(
    
    name: r'days_to_payday',
    required: true,
    includeIfNull: true,
  )


  final int? daysToPayday;



  @JsonKey(
    
    name: r'per_day',
    required: true,
    includeIfNull: true,
  )


  final String? perDay;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CycleSummaryOut &&
      other.carried == carried &&
      other.payroll == payroll &&
      other.opening == opening &&
      other.availableNow == availableNow &&
      other.expectedEnd == expectedEnd &&
      other.netMovements == netMovements &&
      other.pendingTotal == pendingTotal &&
      other.fixedSpend == fixedSpend &&
      other.variableSpend == variableSpend &&
      other.installments == installments &&
      other.savings == savings &&
      other.savingsRate == savingsRate &&
      other.daysToPayday == daysToPayday &&
      other.perDay == perDay;

    @override
    int get hashCode =>
        carried.hashCode +
        payroll.hashCode +
        opening.hashCode +
        availableNow.hashCode +
        expectedEnd.hashCode +
        netMovements.hashCode +
        pendingTotal.hashCode +
        fixedSpend.hashCode +
        variableSpend.hashCode +
        installments.hashCode +
        savings.hashCode +
        (savingsRate == null ? 0 : savingsRate.hashCode) +
        (daysToPayday == null ? 0 : daysToPayday.hashCode) +
        (perDay == null ? 0 : perDay.hashCode);

  factory CycleSummaryOut.fromJson(Map<String, dynamic> json) => _$CycleSummaryOutFromJson(json);

  Map<String, dynamic> toJson() => _$CycleSummaryOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

