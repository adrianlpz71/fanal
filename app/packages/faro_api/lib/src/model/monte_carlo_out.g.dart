// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monte_carlo_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonteCarloOut _$MonteCarloOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MonteCarloOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'simulations',
            'volatility',
            'horizon_age',
            'target_age',
            'success',
            'reach',
            'fi_age_p10',
            'fi_age_p50',
            'fi_age_p90',
            'depletion_median_age',
            'bands',
          ],
        );
        final val = MonteCarloOut(
          simulations: $checkedConvert(
            'simulations',
            (v) => (v as num).toInt(),
          ),
          volatility: $checkedConvert('volatility', (v) => v as String),
          horizonAge: $checkedConvert('horizon_age', (v) => (v as num).toInt()),
          targetAge: $checkedConvert('target_age', (v) => (v as num).toInt()),
          success: $checkedConvert('success', (v) => v as String),
          reach: $checkedConvert('reach', (v) => v as String),
          fiAgeP10: $checkedConvert('fi_age_p10', (v) => (v as num?)?.toInt()),
          fiAgeP50: $checkedConvert('fi_age_p50', (v) => (v as num?)?.toInt()),
          fiAgeP90: $checkedConvert('fi_age_p90', (v) => (v as num?)?.toInt()),
          depletionMedianAge: $checkedConvert(
            'depletion_median_age',
            (v) => (v as num?)?.toInt(),
          ),
          bands: $checkedConvert(
            'bands',
            (v) => (v as List<dynamic>)
                .map((e) => BandOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'horizonAge': 'horizon_age',
        'targetAge': 'target_age',
        'fiAgeP10': 'fi_age_p10',
        'fiAgeP50': 'fi_age_p50',
        'fiAgeP90': 'fi_age_p90',
        'depletionMedianAge': 'depletion_median_age',
      },
    );

Map<String, dynamic> _$MonteCarloOutToJson(MonteCarloOut instance) =>
    <String, dynamic>{
      'simulations': instance.simulations,
      'volatility': instance.volatility,
      'horizon_age': instance.horizonAge,
      'target_age': instance.targetAge,
      'success': instance.success,
      'reach': instance.reach,
      'fi_age_p10': instance.fiAgeP10,
      'fi_age_p50': instance.fiAgeP50,
      'fi_age_p90': instance.fiAgeP90,
      'depletion_median_age': instance.depletionMedianAge,
      'bands': instance.bands.map((e) => e.toJson()).toList(),
    };
