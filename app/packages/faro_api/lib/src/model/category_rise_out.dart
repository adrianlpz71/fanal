//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_rise_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryRiseOut {
  /// Returns a new [CategoryRiseOut] instance.
  CategoryRiseOut({

    required  this.name,

    required  this.amount,

    required  this.previous,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: false,
  )


  final String previous;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryRiseOut &&
      other.name == name &&
      other.amount == amount &&
      other.previous == previous;

    @override
    int get hashCode =>
        name.hashCode +
        amount.hashCode +
        previous.hashCode;

  factory CategoryRiseOut.fromJson(Map<String, dynamic> json) => _$CategoryRiseOutFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryRiseOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

