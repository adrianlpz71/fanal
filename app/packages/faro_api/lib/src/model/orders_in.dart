//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/order_in.dart';
import 'package:json_annotation/json_annotation.dart';

part 'orders_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrdersIn {
  /// Returns a new [OrdersIn] instance.
  OrdersIn({

    required  this.orders,

    required  this.tradeDate,

     this.fromAccountId,
  });

  @JsonKey(
    
    name: r'orders',
    required: true,
    includeIfNull: false,
  )


  final List<OrderIn> orders;



  @JsonKey(
    
    name: r'trade_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime tradeDate;



  @JsonKey(
    
    name: r'from_account_id',
    required: false,
    includeIfNull: false,
  )


  final String? fromAccountId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrdersIn &&
      other.orders == orders &&
      other.tradeDate == tradeDate &&
      other.fromAccountId == fromAccountId;

    @override
    int get hashCode =>
        orders.hashCode +
        tradeDate.hashCode +
        (fromAccountId == null ? 0 : fromAccountId.hashCode);

  factory OrdersIn.fromJson(Map<String, dynamic> json) => _$OrdersInFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

