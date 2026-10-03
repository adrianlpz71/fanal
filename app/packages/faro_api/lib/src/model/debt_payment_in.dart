//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'debt_payment_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DebtPaymentIn {
  /// Returns a new [DebtPaymentIn] instance.
  DebtPaymentIn({

    required  this.amount,

     this.date,

     this.concept,
  });

      /// Positivo: lo que pagas (debo) o te pagan (me deben)
  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'concept',
    required: false,
    includeIfNull: false,
  )


  final String? concept;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DebtPaymentIn &&
      other.amount == amount &&
      other.date == date &&
      other.concept == concept;

    @override
    int get hashCode =>
        amount.hashCode +
        (date == null ? 0 : date.hashCode) +
        (concept == null ? 0 : concept.hashCode);

  factory DebtPaymentIn.fromJson(Map<String, dynamic> json) => _$DebtPaymentInFromJson(json);

  Map<String, dynamic> toJson() => _$DebtPaymentInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

