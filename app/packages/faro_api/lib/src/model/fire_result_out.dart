//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fire_result_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FireResultOut {
  /// Returns a new [FireResultOut] instance.
  FireResultOut({

    required  this.realReturn,

    required  this.needed,

    required  this.neededNominal,

    required  this.progress,

    required  this.requiredMonthly,

    required  this.fiAge,

    required  this.coast,

    required  this.coastReached,

    required  this.bridge,
  });

  @JsonKey(
    
    name: r'real_return',
    required: true,
    includeIfNull: false,
  )


  final String realReturn;



  @JsonKey(
    
    name: r'needed',
    required: true,
    includeIfNull: false,
  )


  final String needed;



  @JsonKey(
    
    name: r'needed_nominal',
    required: true,
    includeIfNull: false,
  )


  final String neededNominal;



  @JsonKey(
    
    name: r'progress',
    required: true,
    includeIfNull: false,
  )


  final String progress;



  @JsonKey(
    
    name: r'required_monthly',
    required: true,
    includeIfNull: false,
  )


  final String requiredMonthly;



  @JsonKey(
    
    name: r'fi_age',
    required: true,
    includeIfNull: true,
  )


  final String? fiAge;



  @JsonKey(
    
    name: r'coast',
    required: true,
    includeIfNull: false,
  )


  final String coast;



  @JsonKey(
    
    name: r'coast_reached',
    required: true,
    includeIfNull: false,
  )


  final bool coastReached;



  @JsonKey(
    
    name: r'bridge',
    required: true,
    includeIfNull: false,
  )


  final String bridge;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FireResultOut &&
      other.realReturn == realReturn &&
      other.needed == needed &&
      other.neededNominal == neededNominal &&
      other.progress == progress &&
      other.requiredMonthly == requiredMonthly &&
      other.fiAge == fiAge &&
      other.coast == coast &&
      other.coastReached == coastReached &&
      other.bridge == bridge;

    @override
    int get hashCode =>
        realReturn.hashCode +
        needed.hashCode +
        neededNominal.hashCode +
        progress.hashCode +
        requiredMonthly.hashCode +
        (fiAge == null ? 0 : fiAge.hashCode) +
        coast.hashCode +
        coastReached.hashCode +
        bridge.hashCode;

  factory FireResultOut.fromJson(Map<String, dynamic> json) => _$FireResultOutFromJson(json);

  Map<String, dynamic> toJson() => _$FireResultOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

