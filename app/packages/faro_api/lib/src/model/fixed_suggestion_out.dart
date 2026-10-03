//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fixed_suggestion_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FixedSuggestionOut {
  /// Returns a new [FixedSuggestionOut] instance.
  FixedSuggestionOut({

    required  this.concept,

    required  this.amount,

    required  this.cycles,

    required  this.dayOfMonth,

    required  this.categoryId,
  });

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
    
    name: r'cycles',
    required: true,
    includeIfNull: false,
  )


  final int cycles;



  @JsonKey(
    
    name: r'day_of_month',
    required: true,
    includeIfNull: false,
  )


  final int dayOfMonth;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FixedSuggestionOut &&
      other.concept == concept &&
      other.amount == amount &&
      other.cycles == cycles &&
      other.dayOfMonth == dayOfMonth &&
      other.categoryId == categoryId;

    @override
    int get hashCode =>
        concept.hashCode +
        amount.hashCode +
        cycles.hashCode +
        dayOfMonth.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode);

  factory FixedSuggestionOut.fromJson(Map<String, dynamic> json) => _$FixedSuggestionOutFromJson(json);

  Map<String, dynamic> toJson() => _$FixedSuggestionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

