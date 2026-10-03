//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/fixed_suggestion_out.dart';
import 'package:faro_api/src/model/fixed_item_out.dart';
import 'package:faro_api/src/model/fixed_trend_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fixed_panel_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FixedPanelOut {
  /// Returns a new [FixedPanelOut] instance.
  FixedPanelOut({

    required  this.items,

    required  this.monthlyTotal,

    required  this.yearlyTotal,

    required  this.payroll,

    required  this.shareOfPayroll,

    required  this.trend,

    required  this.goalMax,

    required  this.goalName,

    required  this.savedYear,

    required  this.toReviewSaving,

    required  this.suggestions,

    required  this.reviewDue,

    required  this.lastReview,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<FixedItemOut> items;



  @JsonKey(
    
    name: r'monthly_total',
    required: true,
    includeIfNull: false,
  )


  final String monthlyTotal;



  @JsonKey(
    
    name: r'yearly_total',
    required: true,
    includeIfNull: false,
  )


  final String yearlyTotal;



  @JsonKey(
    
    name: r'payroll',
    required: true,
    includeIfNull: true,
  )


  final String? payroll;



  @JsonKey(
    
    name: r'share_of_payroll',
    required: true,
    includeIfNull: true,
  )


  final String? shareOfPayroll;



  @JsonKey(
    
    name: r'trend',
    required: true,
    includeIfNull: false,
  )


  final List<FixedTrendOut> trend;



  @JsonKey(
    
    name: r'goal_max',
    required: true,
    includeIfNull: true,
  )


  final String? goalMax;



  @JsonKey(
    
    name: r'goal_name',
    required: true,
    includeIfNull: true,
  )


  final String? goalName;



  @JsonKey(
    
    name: r'saved_year',
    required: true,
    includeIfNull: false,
  )


  final String savedYear;



  @JsonKey(
    
    name: r'to_review_saving',
    required: true,
    includeIfNull: false,
  )


  final String toReviewSaving;



  @JsonKey(
    
    name: r'suggestions',
    required: true,
    includeIfNull: false,
  )


  final List<FixedSuggestionOut> suggestions;



  @JsonKey(
    
    name: r'review_due',
    required: true,
    includeIfNull: false,
  )


  final bool reviewDue;



  @JsonKey(
    
    name: r'last_review',
    required: true,
    includeIfNull: true,
  )


  final DateTime? lastReview;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FixedPanelOut &&
      other.items == items &&
      other.monthlyTotal == monthlyTotal &&
      other.yearlyTotal == yearlyTotal &&
      other.payroll == payroll &&
      other.shareOfPayroll == shareOfPayroll &&
      other.trend == trend &&
      other.goalMax == goalMax &&
      other.goalName == goalName &&
      other.savedYear == savedYear &&
      other.toReviewSaving == toReviewSaving &&
      other.suggestions == suggestions &&
      other.reviewDue == reviewDue &&
      other.lastReview == lastReview;

    @override
    int get hashCode =>
        items.hashCode +
        monthlyTotal.hashCode +
        yearlyTotal.hashCode +
        (payroll == null ? 0 : payroll.hashCode) +
        (shareOfPayroll == null ? 0 : shareOfPayroll.hashCode) +
        trend.hashCode +
        (goalMax == null ? 0 : goalMax.hashCode) +
        (goalName == null ? 0 : goalName.hashCode) +
        savedYear.hashCode +
        toReviewSaving.hashCode +
        suggestions.hashCode +
        reviewDue.hashCode +
        (lastReview == null ? 0 : lastReview.hashCode);

  factory FixedPanelOut.fromJson(Map<String, dynamic> json) => _$FixedPanelOutFromJson(json);

  Map<String, dynamic> toJson() => _$FixedPanelOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

