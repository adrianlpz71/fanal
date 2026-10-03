//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'correction_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CorrectionIn {
  /// Returns a new [CorrectionIn] instance.
  CorrectionIn({

    required  this.units,

    required  this.avgCost,

    required  this.reason,

     this.effectiveDate,
  });

  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'avg_cost',
    required: true,
    includeIfNull: false,
  )


  final String avgCost;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;



  @JsonKey(
    
    name: r'effective_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? effectiveDate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CorrectionIn &&
      other.units == units &&
      other.avgCost == avgCost &&
      other.reason == reason &&
      other.effectiveDate == effectiveDate;

    @override
    int get hashCode =>
        units.hashCode +
        avgCost.hashCode +
        reason.hashCode +
        (effectiveDate == null ? 0 : effectiveDate.hashCode);

  factory CorrectionIn.fromJson(Map<String, dynamic> json) => _$CorrectionInFromJson(json);

  Map<String, dynamic> toJson() => _$CorrectionInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

