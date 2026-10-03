//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'review_goal_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReviewGoalOut {
  /// Returns a new [ReviewGoalOut] instance.
  ReviewGoalOut({

    required  this.name,

    required  this.progress,

    required  this.onTrack,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'progress',
    required: true,
    includeIfNull: true,
  )


  final String? progress;



  @JsonKey(
    
    name: r'on_track',
    required: true,
    includeIfNull: true,
  )


  final bool? onTrack;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReviewGoalOut &&
      other.name == name &&
      other.progress == progress &&
      other.onTrack == onTrack;

    @override
    int get hashCode =>
        name.hashCode +
        (progress == null ? 0 : progress.hashCode) +
        (onTrack == null ? 0 : onTrack.hashCode);

  factory ReviewGoalOut.fromJson(Map<String, dynamic> json) => _$ReviewGoalOutFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewGoalOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

