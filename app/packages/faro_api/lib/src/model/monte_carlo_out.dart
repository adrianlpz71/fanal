//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/band_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'monte_carlo_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MonteCarloOut {
  /// Returns a new [MonteCarloOut] instance.
  MonteCarloOut({

    required  this.simulations,

    required  this.volatility,

    required  this.horizonAge,

    required  this.targetAge,

    required  this.success,

    required  this.reach,

    required  this.fiAgeP10,

    required  this.fiAgeP50,

    required  this.fiAgeP90,

    required  this.depletionMedianAge,

    required  this.bands,
  });

  @JsonKey(
    
    name: r'simulations',
    required: true,
    includeIfNull: false,
  )


  final int simulations;



  @JsonKey(
    
    name: r'volatility',
    required: true,
    includeIfNull: false,
  )


  final String volatility;



  @JsonKey(
    
    name: r'horizon_age',
    required: true,
    includeIfNull: false,
  )


  final int horizonAge;



  @JsonKey(
    
    name: r'target_age',
    required: true,
    includeIfNull: false,
  )


  final int targetAge;



  @JsonKey(
    
    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final String success;



  @JsonKey(
    
    name: r'reach',
    required: true,
    includeIfNull: false,
  )


  final String reach;



  @JsonKey(
    
    name: r'fi_age_p10',
    required: true,
    includeIfNull: true,
  )


  final int? fiAgeP10;



  @JsonKey(
    
    name: r'fi_age_p50',
    required: true,
    includeIfNull: true,
  )


  final int? fiAgeP50;



  @JsonKey(
    
    name: r'fi_age_p90',
    required: true,
    includeIfNull: true,
  )


  final int? fiAgeP90;



  @JsonKey(
    
    name: r'depletion_median_age',
    required: true,
    includeIfNull: true,
  )


  final int? depletionMedianAge;



  @JsonKey(
    
    name: r'bands',
    required: true,
    includeIfNull: false,
  )


  final List<BandOut> bands;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MonteCarloOut &&
      other.simulations == simulations &&
      other.volatility == volatility &&
      other.horizonAge == horizonAge &&
      other.targetAge == targetAge &&
      other.success == success &&
      other.reach == reach &&
      other.fiAgeP10 == fiAgeP10 &&
      other.fiAgeP50 == fiAgeP50 &&
      other.fiAgeP90 == fiAgeP90 &&
      other.depletionMedianAge == depletionMedianAge &&
      other.bands == bands;

    @override
    int get hashCode =>
        simulations.hashCode +
        volatility.hashCode +
        horizonAge.hashCode +
        targetAge.hashCode +
        success.hashCode +
        reach.hashCode +
        (fiAgeP10 == null ? 0 : fiAgeP10.hashCode) +
        (fiAgeP50 == null ? 0 : fiAgeP50.hashCode) +
        (fiAgeP90 == null ? 0 : fiAgeP90.hashCode) +
        (depletionMedianAge == null ? 0 : depletionMedianAge.hashCode) +
        bands.hashCode;

  factory MonteCarloOut.fromJson(Map<String, dynamic> json) => _$MonteCarloOutFromJson(json);

  Map<String, dynamic> toJson() => _$MonteCarloOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

