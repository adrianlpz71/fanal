//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'plan_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanIn {
  /// Returns a new [PlanIn] instance.
  PlanIn({

     this.id,

    required  this.assetId,

    required  this.amount,

     this.everyMonths = 1,

     this.dayOfMonth = 1,

    required  this.startDate,

     this.endDate,

     this.active = true,

     this.fromAccountId,

     this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



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



          // minimum: 1
          // maximum: 12
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
    defaultValue: true,
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;



  @JsonKey(
    
    name: r'from_account_id',
    required: false,
    includeIfNull: false,
  )


  final String? fromAccountId;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlanIn &&
      other.id == id &&
      other.assetId == assetId &&
      other.amount == amount &&
      other.everyMonths == everyMonths &&
      other.dayOfMonth == dayOfMonth &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.active == active &&
      other.fromAccountId == fromAccountId &&
      other.notes == notes;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        assetId.hashCode +
        amount.hashCode +
        everyMonths.hashCode +
        dayOfMonth.hashCode +
        startDate.hashCode +
        (endDate == null ? 0 : endDate.hashCode) +
        active.hashCode +
        (fromAccountId == null ? 0 : fromAccountId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory PlanIn.fromJson(Map<String, dynamic> json) => _$PlanInFromJson(json);

  Map<String, dynamic> toJson() => _$PlanInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

