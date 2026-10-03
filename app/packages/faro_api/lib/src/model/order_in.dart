//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'order_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderIn {
  /// Returns a new [OrderIn] instance.
  OrderIn({

    required  this.assetId,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderIn &&
      other.assetId == assetId &&
      other.amount == amount;

    @override
    int get hashCode =>
        assetId.hashCode +
        amount.hashCode;

  factory OrderIn.fromJson(Map<String, dynamic> json) => _$OrderInFromJson(json);

  Map<String, dynamic> toJson() => _$OrderInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

