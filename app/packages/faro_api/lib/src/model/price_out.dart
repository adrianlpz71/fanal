//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'price_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PriceOut {
  /// Returns a new [PriceOut] instance.
  PriceOut({

    required  this.date,

    required  this.price,

    required  this.source_,
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



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PriceOut &&
      other.date == date &&
      other.price == price &&
      other.source_ == source_;

    @override
    int get hashCode =>
        date.hashCode +
        price.hashCode +
        source_.hashCode;

  factory PriceOut.fromJson(Map<String, dynamic> json) => _$PriceOutFromJson(json);

  Map<String, dynamic> toJson() => _$PriceOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

