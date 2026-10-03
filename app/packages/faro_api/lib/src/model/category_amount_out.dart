//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_amount_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryAmountOut {
  /// Returns a new [CategoryAmountOut] instance.
  CategoryAmountOut({

    required  this.categoryId,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryAmountOut &&
      other.categoryId == categoryId &&
      other.amount == amount;

    @override
    int get hashCode =>
        (categoryId == null ? 0 : categoryId.hashCode) +
        amount.hashCode;

  factory CategoryAmountOut.fromJson(Map<String, dynamic> json) => _$CategoryAmountOutFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryAmountOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

