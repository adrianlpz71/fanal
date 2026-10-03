// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioOut _$PortfolioOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PortfolioOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'value',
          'cost',
          'pnl',
          'pnl_pct',
          'pending',
          'stale',
          'classes',
          'unclassified',
          'emergency',
        ],
      );
      final val = PortfolioOut(
        value: $checkedConvert('value', (v) => v as String),
        cost: $checkedConvert('cost', (v) => v as String),
        pnl: $checkedConvert('pnl', (v) => v as String),
        pnlPct: $checkedConvert('pnl_pct', (v) => v as String?),
        pending: $checkedConvert('pending', (v) => v as String),
        stale: $checkedConvert('stale', (v) => (v as num).toInt()),
        classes: $checkedConvert(
          'classes',
          (v) => (v as List<dynamic>)
              .map((e) => ClassOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        unclassified: $checkedConvert(
          'unclassified',
          (v) => (v as List<dynamic>)
              .map((e) => PositionOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        emergency: $checkedConvert(
          'emergency',
          (v) => v == null
              ? null
              : EmergencyOut.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'pnlPct': 'pnl_pct'});

Map<String, dynamic> _$PortfolioOutToJson(PortfolioOut instance) =>
    <String, dynamic>{
      'value': instance.value,
      'cost': instance.cost,
      'pnl': instance.pnl,
      'pnl_pct': instance.pnlPct,
      'pending': instance.pending,
      'stale': instance.stale,
      'classes': instance.classes.map((e) => e.toJson()).toList(),
      'unclassified': instance.unclassified.map((e) => e.toJson()).toList(),
      'emergency': instance.emergency?.toJson(),
    };
