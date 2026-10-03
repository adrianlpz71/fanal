//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tax_bracket_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaxBracketOut {
  /// Returns a new [TaxBracketOut] instance.
  TaxBracketOut({

    required  this.lo,

    required  this.hi,

    required  this.rate,

    required  this.amount,

    required  this.tax,
  });

  @JsonKey(
    
    name: r'lo',
    required: true,
    includeIfNull: false,
  )


  final String lo;



  @JsonKey(
    
    name: r'hi',
    required: true,
    includeIfNull: true,
  )


  final String? hi;



  @JsonKey(
    
    name: r'rate',
    required: true,
    includeIfNull: false,
  )


  final String rate;



      /// Lo que cae en este tramo
  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'tax',
    required: true,
    includeIfNull: false,
  )


  final String tax;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaxBracketOut &&
      other.lo == lo &&
      other.hi == hi &&
      other.rate == rate &&
      other.amount == amount &&
      other.tax == tax;

    @override
    int get hashCode =>
        lo.hashCode +
        (hi == null ? 0 : hi.hashCode) +
        rate.hashCode +
        amount.hashCode +
        tax.hashCode;

  factory TaxBracketOut.fromJson(Map<String, dynamic> json) => _$TaxBracketOutFromJson(json);

  Map<String, dynamic> toJson() => _$TaxBracketOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

