// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestones_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilestonesIn _$MilestonesInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MilestonesIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['thresholds']);
      final val = MilestonesIn(
        thresholds: $checkedConvert(
          'thresholds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MilestonesInToJson(MilestonesIn instance) =>
    <String, dynamic>{'thresholds': instance.thresholds};
