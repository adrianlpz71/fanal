//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'price_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PriceIn {
  /// Returns a new [PriceIn] instance.
  PriceIn({

    required  this.date,

    required  this.price,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'price',
    required: true,
    includeIfNull: false,
  )


  final String price;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PriceIn &&
      other.date == date &&
      other.price == price;

    @override
    int get hashCode =>
        date.hashCode +
        price.hashCode;

  factory PriceIn.fromJson(Map<String, dynamic> json) => _$PriceInFromJson(json);

  Map<String, dynamic> toJson() => _$PriceInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

