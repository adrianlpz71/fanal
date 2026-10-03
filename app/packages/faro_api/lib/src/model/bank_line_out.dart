//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'bank_line_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BankLineOut {
  /// Returns a new [BankLineOut] instance.
  BankLineOut({

    required  this.row,

    required  this.date,

    required  this.concept,

    required  this.amount,

    required  this.balance,

    required  this.outcome,

    required  this.movementId,

    required  this.categoryId,
  });

  @JsonKey(
    
    name: r'row',
    required: true,
    includeIfNull: false,
  )


  final int row;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



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
    
    name: r'balance',
    required: true,
    includeIfNull: true,
  )


  final String? balance;



  @JsonKey(
    
    name: r'outcome',
    required: true,
    includeIfNull: false,
  )


  final String outcome;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? movementId;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BankLineOut &&
      other.row == row &&
      other.date == date &&
      other.concept == concept &&
      other.amount == amount &&
      other.balance == balance &&
      other.outcome == outcome &&
      other.movementId == movementId &&
      other.categoryId == categoryId;

    @override
    int get hashCode =>
        row.hashCode +
        date.hashCode +
        concept.hashCode +
        amount.hashCode +
        (balance == null ? 0 : balance.hashCode) +
        outcome.hashCode +
        (movementId == null ? 0 : movementId.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode);

  factory BankLineOut.fromJson(Map<String, dynamic> json) => _$BankLineOutFromJson(json);

  Map<String, dynamic> toJson() => _$BankLineOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

