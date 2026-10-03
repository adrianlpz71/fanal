//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionOut {
  /// Returns a new [SuggestionOut] instance.
  SuggestionOut({

    required  this.concept,

    required  this.categoryId,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: true,
  )


  final String? amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SuggestionOut &&
      other.concept == concept &&
      other.categoryId == categoryId &&
      other.amount == amount;

    @override
    int get hashCode =>
        concept.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (amount == null ? 0 : amount.hashCode);

  factory SuggestionOut.fromJson(Map<String, dynamic> json) => _$SuggestionOutFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

