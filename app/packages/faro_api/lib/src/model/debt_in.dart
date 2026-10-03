//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'debt_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DebtIn {
  /// Returns a new [DebtIn] instance.
  DebtIn({

    required  this.name,

     this.personName,

     this.direction,

    required  this.openingBalance,

    required  this.openingDate,

     this.interestRate,

     this.notes,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'person_name',
    required: false,
    includeIfNull: false,
  )


  final String? personName;



  @JsonKey(
    
    name: r'direction',
    required: false,
    includeIfNull: false,
  )


  final DebtInDirectionEnum? direction;



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
    
    name: r'interest_rate',
    required: false,
    includeIfNull: false,
  )


  final String? interestRate;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DebtIn &&
      other.name == name &&
      other.personName == personName &&
      other.direction == direction &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.interestRate == interestRate &&
      other.notes == notes;

    @override
    int get hashCode =>
        name.hashCode +
        (personName == null ? 0 : personName.hashCode) +
        direction.hashCode +
        openingBalance.hashCode +
        openingDate.hashCode +
        (interestRate == null ? 0 : interestRate.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory DebtIn.fromJson(Map<String, dynamic> json) => _$DebtInFromJson(json);

  Map<String, dynamic> toJson() => _$DebtInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DebtInDirectionEnum {
@JsonValue(r'debo')
debo(r'debo'),
@JsonValue(r'me_deben')
meDeben(r'me_deben');

const DebtInDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}


