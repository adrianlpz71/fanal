//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'rule_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RuleOut {
  /// Returns a new [RuleOut] instance.
  RuleOut({

    required  this.id,

    required  this.pattern,

    required  this.categoryId,

    required  this.source_,

    required  this.hits,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'pattern',
    required: true,
    includeIfNull: false,
  )


  final String pattern;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: false,
  )


  final String categoryId;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'hits',
    required: true,
    includeIfNull: false,
  )


  final int hits;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RuleOut &&
      other.id == id &&
      other.pattern == pattern &&
      other.categoryId == categoryId &&
      other.source_ == source_ &&
      other.hits == hits;

    @override
    int get hashCode =>
        id.hashCode +
        pattern.hashCode +
        categoryId.hashCode +
        source_.hashCode +
        hits.hashCode;

  factory RuleOut.fromJson(Map<String, dynamic> json) => _$RuleOutFromJson(json);

  Map<String, dynamic> toJson() => _$RuleOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

