//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fixed_trend_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FixedTrendOut {
  /// Returns a new [FixedTrendOut] instance.
  FixedTrendOut({

    required  this.label,

    required  this.fixed,
  });

  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'fixed',
    required: true,
    includeIfNull: false,
  )


  final String fixed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FixedTrendOut &&
      other.label == label &&
      other.fixed == fixed;

    @override
    int get hashCode =>
        label.hashCode +
        fixed.hashCode;

  factory FixedTrendOut.fromJson(Map<String, dynamic> json) => _$FixedTrendOutFromJson(json);

  Map<String, dynamic> toJson() => _$FixedTrendOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

