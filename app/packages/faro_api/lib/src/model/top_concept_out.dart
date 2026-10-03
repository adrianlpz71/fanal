//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'top_concept_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TopConceptOut {
  /// Returns a new [TopConceptOut] instance.
  TopConceptOut({

    required  this.concept,

    required  this.total,

    required  this.count,
  });

  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TopConceptOut &&
      other.concept == concept &&
      other.total == total &&
      other.count == count;

    @override
    int get hashCode =>
        concept.hashCode +
        total.hashCode +
        count.hashCode;

  factory TopConceptOut.fromJson(Map<String, dynamic> json) => _$TopConceptOutFromJson(json);

  Map<String, dynamic> toJson() => _$TopConceptOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

