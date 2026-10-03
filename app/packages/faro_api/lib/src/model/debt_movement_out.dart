//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'debt_movement_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DebtMovementOut {
  /// Returns a new [DebtMovementOut] instance.
  DebtMovementOut({

    required  this.id,

    required  this.date,

    required  this.concept,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? date;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is DebtMovementOut &&
      other.id == id &&
      other.date == date &&
      other.concept == concept &&
      other.amount == amount;

    @override
    int get hashCode =>
        id.hashCode +
        (date == null ? 0 : date.hashCode) +
        concept.hashCode +
        amount.hashCode;

  factory DebtMovementOut.fromJson(Map<String, dynamic> json) => _$DebtMovementOutFromJson(json);

  Map<String, dynamic> toJson() => _$DebtMovementOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

