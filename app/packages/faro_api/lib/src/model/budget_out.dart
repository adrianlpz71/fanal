//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'budget_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BudgetOut {
  /// Returns a new [BudgetOut] instance.
  BudgetOut({

    required  this.categoryId,

    required  this.amount,

    required  this.active,
  });

  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: false,
  )


  final String categoryId;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'active',
    required: true,
    includeIfNull: false,
  )


  final bool active;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BudgetOut &&
      other.categoryId == categoryId &&
      other.amount == amount &&
      other.active == active;

    @override
    int get hashCode =>
        categoryId.hashCode +
        amount.hashCode +
        active.hashCode;

  factory BudgetOut.fromJson(Map<String, dynamic> json) => _$BudgetOutFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

