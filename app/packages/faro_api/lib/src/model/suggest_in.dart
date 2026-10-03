//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'suggest_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestIn {
  /// Returns a new [SuggestIn] instance.
  SuggestIn({

    required  this.amount,

     this.roundTo,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'round_to',
    required: false,
    includeIfNull: false,
  )


  final String? roundTo;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SuggestIn &&
      other.amount == amount &&
      other.roundTo == roundTo;

    @override
    int get hashCode =>
        amount.hashCode +
        (roundTo == null ? 0 : roundTo.hashCode);

  factory SuggestIn.fromJson(Map<String, dynamic> json) => _$SuggestInFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

