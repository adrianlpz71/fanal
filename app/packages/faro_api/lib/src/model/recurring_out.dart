//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/price_change_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recurring_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecurringOut {
  /// Returns a new [RecurringOut] instance.
  RecurringOut({

    required  this.id,

    required  this.concept,

    required  this.amount,

    required  this.amountIsEstimate,

    required  this.kind,

    required  this.categoryId,

    required  this.everyMonths,

    required  this.dayOfMonth,

    required  this.startDate,

    required  this.endDate,

    required  this.active,

    required  this.review,

    required  this.estSavingYear,

    required  this.monthlyCost,

    required  this.yearlyCost,

    required  this.priceChanges,

    required  this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'amount_is_estimate',
    required: true,
    includeIfNull: false,
  )


  final bool amountIsEstimate;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final RecurringOutKindEnum kind;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'every_months',
    required: true,
    includeIfNull: false,
  )


  final int everyMonths;



  @JsonKey(
    
    name: r'day_of_month',
    required: true,
    includeIfNull: false,
  )


  final int dayOfMonth;



  @JsonKey(
    
    name: r'start_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime startDate;



  @JsonKey(
    
    name: r'end_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? endDate;



  @JsonKey(
    
    name: r'active',
    required: true,
    includeIfNull: false,
  )


  final bool active;



  @JsonKey(
    
    name: r'review',
    required: true,
    includeIfNull: false,
  )


  final String review;



  @JsonKey(
    
    name: r'est_saving_year',
    required: true,
    includeIfNull: true,
  )


  final String? estSavingYear;



  @JsonKey(
    
    name: r'monthly_cost',
    required: true,
    includeIfNull: false,
  )


  final String monthlyCost;



  @JsonKey(
    
    name: r'yearly_cost',
    required: true,
    includeIfNull: false,
  )


  final String yearlyCost;



  @JsonKey(
    
    name: r'price_changes',
    required: true,
    includeIfNull: false,
  )


  final List<PriceChangeOut> priceChanges;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecurringOut &&
      other.id == id &&
      other.concept == concept &&
      other.amount == amount &&
      other.amountIsEstimate == amountIsEstimate &&
      other.kind == kind &&
      other.categoryId == categoryId &&
      other.everyMonths == everyMonths &&
      other.dayOfMonth == dayOfMonth &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.active == active &&
      other.review == review &&
      other.estSavingYear == estSavingYear &&
      other.monthlyCost == monthlyCost &&
      other.yearlyCost == yearlyCost &&
      other.priceChanges == priceChanges &&
      other.notes == notes;

    @override
    int get hashCode =>
        id.hashCode +
        concept.hashCode +
        amount.hashCode +
        amountIsEstimate.hashCode +
        kind.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        everyMonths.hashCode +
        dayOfMonth.hashCode +
        startDate.hashCode +
        (endDate == null ? 0 : endDate.hashCode) +
        active.hashCode +
        review.hashCode +
        (estSavingYear == null ? 0 : estSavingYear.hashCode) +
        monthlyCost.hashCode +
        yearlyCost.hashCode +
        priceChanges.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory RecurringOut.fromJson(Map<String, dynamic> json) => _$RecurringOutFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RecurringOutKindEnum {
@JsonValue(r'gasto')
gasto(r'gasto'),
@JsonValue(r'ingreso')
ingreso(r'ingreso'),
@JsonValue(r'nomina')
nomina(r'nomina'),
@JsonValue(r'transferencia')
transferencia(r'transferencia'),
@JsonValue(r'reembolso')
reembolso(r'reembolso'),
@JsonValue(r'ajuste')
ajuste(r'ajuste');

const RecurringOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


