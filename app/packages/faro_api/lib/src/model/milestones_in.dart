//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'milestones_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MilestonesIn {
  /// Returns a new [MilestonesIn] instance.
  MilestonesIn({

    required  this.thresholds,
  });

  @JsonKey(
    
    name: r'thresholds',
    required: true,
    includeIfNull: false,
  )


  final List<String> thresholds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MilestonesIn &&
      other.thresholds == thresholds;

    @override
    int get hashCode =>
        thresholds.hashCode;

  factory MilestonesIn.fromJson(Map<String, dynamic> json) => _$MilestonesInFromJson(json);

  Map<String, dynamic> toJson() => _$MilestonesInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

