//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'recurring_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecurringIn {
  /// Returns a new [RecurringIn] instance.
  RecurringIn({

    required  this.concept,

    required  this.amount,

     this.amountIsEstimate = false,

     this.kind,

     this.categoryId,

     this.everyMonths = 1,

     this.dayOfMonth = 1,

    required  this.startDate,

     this.endDate,

     this.accountId,

     this.notes,
  });

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
    defaultValue: false,
    name: r'amount_is_estimate',
    required: false,
    includeIfNull: false,
  )


  final bool? amountIsEstimate;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final RecurringInKindEnum? kind;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



          // minimum: 1
          // maximum: 24
  @JsonKey(
    defaultValue: 1,
    name: r'every_months',
    required: false,
    includeIfNull: false,
  )


  final int? everyMonths;



          // minimum: 1
          // maximum: 31
  @JsonKey(
    defaultValue: 1,
    name: r'day_of_month',
    required: false,
    includeIfNull: false,
  )


  final int? dayOfMonth;



  @JsonKey(
    
    name: r'start_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime startDate;



  @JsonKey(
    
    name: r'end_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endDate;



  @JsonKey(
    
    name: r'account_id',
    required: false,
    includeIfNull: false,
  )


  final String? accountId;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecurringIn &&
      other.concept == concept &&
      other.amount == amount &&
      other.amountIsEstimate == amountIsEstimate &&
      other.kind == kind &&
      other.categoryId == categoryId &&
      other.everyMonths == everyMonths &&
      other.dayOfMonth == dayOfMonth &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.accountId == accountId &&
      other.notes == notes;

    @override
    int get hashCode =>
        concept.hashCode +
        amount.hashCode +
        amountIsEstimate.hashCode +
        kind.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        everyMonths.hashCode +
        dayOfMonth.hashCode +
        startDate.hashCode +
        (endDate == null ? 0 : endDate.hashCode) +
        (accountId == null ? 0 : accountId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory RecurringIn.fromJson(Map<String, dynamic> json) => _$RecurringInFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RecurringInKindEnum {
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

const RecurringInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


