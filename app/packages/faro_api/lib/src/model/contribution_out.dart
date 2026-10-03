//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/order_out.dart';
import 'package:faro_api/src/model/class_amount_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contribution_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContributionOut {
  /// Returns a new [ContributionOut] instance.
  ContributionOut({

    required  this.amount,

    required  this.byClass,

    required  this.orders,

    required  this.unassigned,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'by_class',
    required: true,
    includeIfNull: false,
  )


  final List<ClassAmountOut> byClass;



  @JsonKey(
    
    name: r'orders',
    required: true,
    includeIfNull: false,
  )


  final List<OrderOut> orders;



  @JsonKey(
    
    name: r'unassigned',
    required: true,
    includeIfNull: false,
  )


  final String unassigned;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContributionOut &&
      other.amount == amount &&
      other.byClass == byClass &&
      other.orders == orders &&
      other.unassigned == unassigned;

    @override
    int get hashCode =>
        amount.hashCode +
        byClass.hashCode +
        orders.hashCode +
        unassigned.hashCode;

  factory ContributionOut.fromJson(Map<String, dynamic> json) => _$ContributionOutFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

