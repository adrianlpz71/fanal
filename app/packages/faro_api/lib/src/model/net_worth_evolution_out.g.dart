// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_evolution_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetWorthEvolutionOut _$NetWorthEvolutionOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NetWorthEvolutionOut', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['start', 'per_cycle_until', 'components', 'points'],
  );
  final val = NetWorthEvolutionOut(
    start: $checkedConvert(
      'start',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    perCycleUntil: $checkedConvert(
      'per_cycle_until',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    components: $checkedConvert(
      'components',
      (v) => (v as List<dynamic>)
          .map((e) => NetWorthComponentOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    points: $checkedConvert(
      'points',
      (v) => (v as List<dynamic>)
          .map((e) => EvolutionPointOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'perCycleUntil': 'per_cycle_until'});

Map<String, dynamic> _$NetWorthEvolutionOutToJson(
  NetWorthEvolutionOut instance,
) => <String, dynamic>{
  'start': instance.start?.toIso8601String(),
  'per_cycle_until': instance.perCycleUntil?.toIso8601String(),
  'components': instance.components.map((e) => e.toJson()).toList(),
  'points': instance.points.map((e) => e.toJson()).toList(),
};
