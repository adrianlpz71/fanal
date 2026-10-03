// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contributions_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionsOut _$ContributionsOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ContributionsOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'this_month',
            'this_year',
            'total',
            'withdrawn',
            'starting',
            'pace',
            'streak',
            'pace_investing',
            'streak_investing',
            'track_start',
            'destinations',
            'months',
            'items',
          ],
        );
        final val = ContributionsOut(
          thisMonth: $checkedConvert('this_month', (v) => v as String),
          thisYear: $checkedConvert('this_year', (v) => v as String),
          total: $checkedConvert('total', (v) => v as String),
          withdrawn: $checkedConvert('withdrawn', (v) => v as String),
          starting: $checkedConvert('starting', (v) => v as String),
          pace: $checkedConvert('pace', (v) => v as String),
          streak: $checkedConvert('streak', (v) => (v as num).toInt()),
          paceInvesting: $checkedConvert('pace_investing', (v) => v as String),
          streakInvesting: $checkedConvert(
            'streak_investing',
            (v) => (v as num).toInt(),
          ),
          trackStart: $checkedConvert(
            'track_start',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          destinations: $checkedConvert(
            'destinations',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => ContributionDestinationOut.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
          months: $checkedConvert(
            'months',
            (v) => (v as List<dynamic>)
                .map(
                  (e) =>
                      ContributionMonthOut.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>)
                .map(
                  (e) =>
                      ContributionItemOut.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'thisMonth': 'this_month',
        'thisYear': 'this_year',
        'paceInvesting': 'pace_investing',
        'streakInvesting': 'streak_investing',
        'trackStart': 'track_start',
      },
    );

Map<String, dynamic> _$ContributionsOutToJson(ContributionsOut instance) =>
    <String, dynamic>{
      'this_month': instance.thisMonth,
      'this_year': instance.thisYear,
      'total': instance.total,
      'withdrawn': instance.withdrawn,
      'starting': instance.starting,
      'pace': instance.pace,
      'streak': instance.streak,
      'pace_investing': instance.paceInvesting,
      'streak_investing': instance.streakInvesting,
      'track_start': instance.trackStart?.toIso8601String(),
      'destinations': instance.destinations.map((e) => e.toJson()).toList(),
      'months': instance.months.map((e) => e.toJson()).toList(),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
