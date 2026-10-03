// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advance_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvanceIn _$AdvanceInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdvanceIn', json, ($checkedConvert) {
      final val = AdvanceIn(
        merge: $checkedConvert('merge', (v) => v as bool? ?? true),
      );
      return val;
    });

Map<String, dynamic> _$AdvanceInToJson(AdvanceIn instance) => <String, dynamic>{
  'merge': ?instance.merge,
};
