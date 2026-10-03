//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'class_amount_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClassAmountOut {
  /// Returns a new [ClassAmountOut] instance.
  ClassAmountOut({

    required  this.assetClassId,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'asset_class_id',
    required: true,
    includeIfNull: false,
  )


  final String assetClassId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ClassAmountOut &&
      other.assetClassId == assetClassId &&
      other.amount == amount;

    @override
    int get hashCode =>
        assetClassId.hashCode +
        amount.hashCode;

  factory ClassAmountOut.fromJson(Map<String, dynamic> json) => _$ClassAmountOutFromJson(json);

  Map<String, dynamic> toJson() => _$ClassAmountOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

