//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/category_amount_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cycle_stats_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CycleStatsOut {
  /// Returns a new [CycleStatsOut] instance.
  CycleStatsOut({

    required  this.cycleId,

    required  this.label,

    required  this.status,

    required  this.payroll,

    required  this.income,

    required  this.spend,

    required  this.fixed,

    required  this.variable,

    required  this.installments,

    required  this.savings,

    required  this.savingsRate,

    required  this.byCategory,
  });

  @JsonKey(
    
    name: r'cycle_id',
    required: true,
    includeIfNull: false,
  )


  final String cycleId;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'payroll',
    required: true,
    includeIfNull: false,
  )


  final String payroll;



  @JsonKey(
    
    name: r'income',
    required: true,
    includeIfNull: false,
  )


  final String income;



  @JsonKey(
    
    name: r'spend',
    required: true,
    includeIfNull: false,
  )


  final String spend;



  @JsonKey(
    
    name: r'fixed',
    required: true,
    includeIfNull: false,
  )


  final String fixed;



  @JsonKey(
    
    name: r'variable',
    required: true,
    includeIfNull: false,
  )


  final String variable;



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
    
    name: r'by_category',
    required: true,
    includeIfNull: false,
  )


  final List<CategoryAmountOut> byCategory;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CycleStatsOut &&
      other.cycleId == cycleId &&
      other.label == label &&
      other.status == status &&
      other.payroll == payroll &&
      other.income == income &&
      other.spend == spend &&
      other.fixed == fixed &&
      other.variable == variable &&
      other.installments == installments &&
      other.savings == savings &&
      other.savingsRate == savingsRate &&
      other.byCategory == byCategory;

    @override
    int get hashCode =>
        cycleId.hashCode +
        label.hashCode +
        status.hashCode +
        payroll.hashCode +
        income.hashCode +
        spend.hashCode +
        fixed.hashCode +
        variable.hashCode +
        installments.hashCode +
        savings.hashCode +
        (savingsRate == null ? 0 : savingsRate.hashCode) +
        byCategory.hashCode;

  factory CycleStatsOut.fromJson(Map<String, dynamic> json) => _$CycleStatsOutFromJson(json);

  Map<String, dynamic> toJson() => _$CycleStatsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

