//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'budget_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BudgetIn {
  /// Returns a new [BudgetIn] instance.
  BudgetIn({

    required  this.amount,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BudgetIn &&
      other.amount == amount;

    @override
    int get hashCode =>
        amount.hashCode;

  factory BudgetIn.fromJson(Map<String, dynamic> json) => _$BudgetInFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

