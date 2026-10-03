//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'quarter_review_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuarterReviewIn {
  /// Returns a new [QuarterReviewIn] instance.
  QuarterReviewIn({

     this.changed = '',

     this.nextSteps = '',
  });

  @JsonKey(
    defaultValue: '',
    name: r'changed',
    required: false,
    includeIfNull: false,
  )


  final String? changed;



  @JsonKey(
    defaultValue: '',
    name: r'next_steps',
    required: false,
    includeIfNull: false,
  )


  final String? nextSteps;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QuarterReviewIn &&
      other.changed == changed &&
      other.nextSteps == nextSteps;

    @override
    int get hashCode =>
        changed.hashCode +
        nextSteps.hashCode;

  factory QuarterReviewIn.fromJson(Map<String, dynamic> json) => _$QuarterReviewInFromJson(json);

  Map<String, dynamic> toJson() => _$QuarterReviewInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

