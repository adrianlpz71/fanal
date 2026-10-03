// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionOut _$ContributionOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ContributionOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['amount', 'by_class', 'orders', 'unassigned'],
      );
      final val = ContributionOut(
        amount: $checkedConvert('amount', (v) => v as String),
        byClass: $checkedConvert(
          'by_class',
          (v) => (v as List<dynamic>)
              .map((e) => ClassAmountOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        orders: $checkedConvert(
          'orders',
          (v) => (v as List<dynamic>)
              .map((e) => OrderOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        unassigned: $checkedConvert('unassigned', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'byClass': 'by_class'});

Map<String, dynamic> _$ContributionOutToJson(ContributionOut instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'by_class': instance.byClass.map((e) => e.toJson()).toList(),
      'orders': instance.orders.map((e) => e.toJson()).toList(),
      'unassigned': instance.unassigned,
    };
