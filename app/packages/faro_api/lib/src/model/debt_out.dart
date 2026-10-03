//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/debt_movement_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'debt_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DebtOut {
  /// Returns a new [DebtOut] instance.
  DebtOut({

    required  this.id,

    required  this.name,

    required  this.personName,

    required  this.direction,

    required  this.openingBalance,

    required  this.openingDate,

    required  this.remaining,

    required  this.paid,

    required  this.status,

    required  this.interestRate,

    required  this.notes,

    required  this.movements,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'person_name',
    required: true,
    includeIfNull: true,
  )


  final String? personName;



  @JsonKey(
    
    name: r'direction',
    required: true,
    includeIfNull: false,
  )


  final DebtOutDirectionEnum direction;



  @JsonKey(
    
    name: r'opening_balance',
    required: true,
    includeIfNull: false,
  )


  final String openingBalance;



  @JsonKey(
    
    name: r'opening_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime openingDate;



  @JsonKey(
    
    name: r'remaining',
    required: true,
    includeIfNull: false,
  )


  final String remaining;



  @JsonKey(
    
    name: r'paid',
    required: true,
    includeIfNull: false,
  )


  final String paid;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final DebtOutStatusEnum status;



  @JsonKey(
    
    name: r'interest_rate',
    required: true,
    includeIfNull: true,
  )


  final String? interestRate;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;



  @JsonKey(
    
    name: r'movements',
    required: true,
    includeIfNull: false,
  )


  final List<DebtMovementOut> movements;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DebtOut &&
      other.id == id &&
      other.name == name &&
      other.personName == personName &&
      other.direction == direction &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.remaining == remaining &&
      other.paid == paid &&
      other.status == status &&
      other.interestRate == interestRate &&
      other.notes == notes &&
      other.movements == movements;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (personName == null ? 0 : personName.hashCode) +
        direction.hashCode +
        openingBalance.hashCode +
        openingDate.hashCode +
        remaining.hashCode +
        paid.hashCode +
        status.hashCode +
        (interestRate == null ? 0 : interestRate.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        movements.hashCode;

  factory DebtOut.fromJson(Map<String, dynamic> json) => _$DebtOutFromJson(json);

  Map<String, dynamic> toJson() => _$DebtOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DebtOutDirectionEnum {
@JsonValue(r'debo')
debo(r'debo'),
@JsonValue(r'me_deben')
meDeben(r'me_deben');

const DebtOutDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}



enum DebtOutStatusEnum {
@JsonValue(r'viva')
viva(r'viva'),
@JsonValue(r'saldada')
saldada(r'saldada');

const DebtOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


