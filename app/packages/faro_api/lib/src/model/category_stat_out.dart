//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_stat_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryStatOut {
  /// Returns a new [CategoryStatOut] instance.
  CategoryStatOut({

    required  this.categoryId,

    required  this.name,

    required  this.current,

    required  this.average,

    required  this.budget,

    required  this.budgetUsed,

    required  this.trend,
  });

  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final String current;



  @JsonKey(
    
    name: r'average',
    required: true,
    includeIfNull: false,
  )


  final String average;



  @JsonKey(
    
    name: r'budget',
    required: true,
    includeIfNull: true,
  )


  final String? budget;



  @JsonKey(
    
    name: r'budget_used',
    required: true,
    includeIfNull: true,
  )


  final String? budgetUsed;



  @JsonKey(
    
    name: r'trend',
    required: true,
    includeIfNull: false,
  )


  final List<String> trend;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryStatOut &&
      other.categoryId == categoryId &&
      other.name == name &&
      other.current == current &&
      other.average == average &&
      other.budget == budget &&
      other.budgetUsed == budgetUsed &&
      other.trend == trend;

    @override
    int get hashCode =>
        (categoryId == null ? 0 : categoryId.hashCode) +
        name.hashCode +
        current.hashCode +
        average.hashCode +
        (budget == null ? 0 : budget.hashCode) +
        (budgetUsed == null ? 0 : budgetUsed.hashCode) +
        trend.hashCode;

  factory CategoryStatOut.fromJson(Map<String, dynamic> json) => _$CategoryStatOutFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryStatOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

