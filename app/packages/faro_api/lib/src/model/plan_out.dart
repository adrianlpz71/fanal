//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'plan_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanOut {
  /// Returns a new [PlanOut] instance.
  PlanOut({

    required  this.id,

    required  this.assetId,

    required  this.amount,

    required  this.everyMonths,

    required  this.dayOfMonth,

    required  this.startDate,

    required  this.endDate,

    required  this.active,

    required  this.fromAccountId,

    required  this.nextDate,

    required  this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



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
    
    name: r'from_account_id',
    required: true,
    includeIfNull: true,
  )


  final String? fromAccountId;



  @JsonKey(
    
    name: r'next_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? nextDate;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlanOut &&
      other.id == id &&
      other.assetId == assetId &&
      other.amount == amount &&
      other.everyMonths == everyMonths &&
      other.dayOfMonth == dayOfMonth &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.active == active &&
      other.fromAccountId == fromAccountId &&
      other.nextDate == nextDate &&
      other.notes == notes;

    @override
    int get hashCode =>
        id.hashCode +
        assetId.hashCode +
        amount.hashCode +
        everyMonths.hashCode +
        dayOfMonth.hashCode +
        startDate.hashCode +
        (endDate == null ? 0 : endDate.hashCode) +
        active.hashCode +
        (fromAccountId == null ? 0 : fromAccountId.hashCode) +
        (nextDate == null ? 0 : nextDate.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory PlanOut.fromJson(Map<String, dynamic> json) => _$PlanOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlanOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

