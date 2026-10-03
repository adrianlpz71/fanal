// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_point_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectionPointOut _$ProjectionPointOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProjectionPointOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['age', 'pessimistic', 'base', 'optimistic'],
      );
      final val = ProjectionPointOut(
        age: $checkedConvert('age', (v) => v as String),
        pessimistic: $checkedConvert('pessimistic', (v) => v as String),
        base_: $checkedConvert('base', (v) => v as String),
        optimistic: $checkedConvert('optimistic', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'base_': 'base'});

Map<String, dynamic> _$ProjectionPointOutToJson(ProjectionPointOut instance) =>
    <String, dynamic>{
      'age': instance.age,
      'pessimistic': instance.pessimistic,
      'base': instance.base_,
      'optimistic': instance.optimistic,
    };
