//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'quarter_item_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuarterItemOut {
  /// Returns a new [QuarterItemOut] instance.
  QuarterItemOut({

    required  this.quarter,

    required  this.label,

    required  this.inProgress,

    required  this.saved,
  });

  @JsonKey(
    
    name: r'quarter',
    required: true,
    includeIfNull: false,
  )


  final String quarter;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'in_progress',
    required: true,
    includeIfNull: false,
  )


  final bool inProgress;



  @JsonKey(
    
    name: r'saved',
    required: true,
    includeIfNull: false,
  )


  final bool saved;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QuarterItemOut &&
      other.quarter == quarter &&
      other.label == label &&
      other.inProgress == inProgress &&
      other.saved == saved;

    @override
    int get hashCode =>
        quarter.hashCode +
        label.hashCode +
        inProgress.hashCode +
        saved.hashCode;

  factory QuarterItemOut.fromJson(Map<String, dynamic> json) => _$QuarterItemOutFromJson(json);

  Map<String, dynamic> toJson() => _$QuarterItemOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

