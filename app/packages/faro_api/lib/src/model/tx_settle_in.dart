//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tx_settle_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TxSettleIn {
  /// Returns a new [TxSettleIn] instance.
  TxSettleIn({

     this.units,

     this.price,

     this.fee,
  });

  @JsonKey(
    
    name: r'units',
    required: false,
    includeIfNull: false,
  )


  final String? units;



  @JsonKey(
    
    name: r'price',
    required: false,
    includeIfNull: false,
  )


  final String? price;



  @JsonKey(
    
    name: r'fee',
    required: false,
    includeIfNull: false,
  )


  final String? fee;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TxSettleIn &&
      other.units == units &&
      other.price == price &&
      other.fee == fee;

    @override
    int get hashCode =>
        (units == null ? 0 : units.hashCode) +
        (price == null ? 0 : price.hashCode) +
        (fee == null ? 0 : fee.hashCode);

  factory TxSettleIn.fromJson(Map<String, dynamic> json) => _$TxSettleInFromJson(json);

  Map<String, dynamic> toJson() => _$TxSettleInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

