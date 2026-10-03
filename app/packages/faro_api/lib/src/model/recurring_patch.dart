//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'recurring_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecurringPatch {
  /// Returns a new [RecurringPatch] instance.
  RecurringPatch({

     this.concept,

     this.amount,

     this.amountIsEstimate,

     this.categoryId,

     this.everyMonths,

     this.dayOfMonth,

     this.endDate,

     this.active,

     this.review,

     this.estSavingYear,

     this.notes,
  });

  @JsonKey(
    
    name: r'concept',
    required: false,
    includeIfNull: false,
  )


  final String? concept;



  @JsonKey(
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final String? amount;



  @JsonKey(
    
    name: r'amount_is_estimate',
    required: false,
    includeIfNull: false,
  )


  final bool? amountIsEstimate;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



          // minimum: 1
          // maximum: 24
  @JsonKey(
    
    name: r'every_months',
    required: false,
    includeIfNull: false,
  )


  final int? everyMonths;



          // minimum: 1
          // maximum: 31
  @JsonKey(
    
    name: r'day_of_month',
    required: false,
    includeIfNull: false,
  )


  final int? dayOfMonth;



  @JsonKey(
    
    name: r'end_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endDate;



  @JsonKey(
    
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;



  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final RecurringPatchReviewEnum? review;



  @JsonKey(
    
    name: r'est_saving_year',
    required: false,
    includeIfNull: false,
  )


  final String? estSavingYear;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecurringPatch &&
      other.concept == concept &&
      other.amount == amount &&
      other.amountIsEstimate == amountIsEstimate &&
      other.categoryId == categoryId &&
      other.everyMonths == everyMonths &&
      other.dayOfMonth == dayOfMonth &&
      other.endDate == endDate &&
      other.active == active &&
      other.review == review &&
      other.estSavingYear == estSavingYear &&
      other.notes == notes;

    @override
    int get hashCode =>
        (concept == null ? 0 : concept.hashCode) +
        (amount == null ? 0 : amount.hashCode) +
        (amountIsEstimate == null ? 0 : amountIsEstimate.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (everyMonths == null ? 0 : everyMonths.hashCode) +
        (dayOfMonth == null ? 0 : dayOfMonth.hashCode) +
        (endDate == null ? 0 : endDate.hashCode) +
        (active == null ? 0 : active.hashCode) +
        (review == null ? 0 : review.hashCode) +
        (estSavingYear == null ? 0 : estSavingYear.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory RecurringPatch.fromJson(Map<String, dynamic> json) => _$RecurringPatchFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RecurringPatchReviewEnum {
@JsonValue(r'ok')
ok(r'ok'),
@JsonValue(r'revisar')
revisar(r'revisar'),
@JsonValue(r'cancelar')
cancelar(r'cancelar');

const RecurringPatchReviewEnum(this.value);

final String value;

@override
String toString() => value;
}


