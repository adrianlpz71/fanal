//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'fixed_item_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FixedItemOut {
  /// Returns a new [FixedItemOut] instance.
  FixedItemOut({

    required  this.kind,

    required  this.id,

    required  this.name,

    required  this.monthly,

    required  this.yearly,

    required  this.review,

    required  this.estSavingYear,

    required  this.priceChanges,

    required  this.ends,

    required  this.categoryId,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final FixedItemOutKindEnum kind;



  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'monthly',
    required: true,
    includeIfNull: false,
  )


  final String monthly;



  @JsonKey(
    
    name: r'yearly',
    required: true,
    includeIfNull: false,
  )


  final String yearly;



  @JsonKey(
    
    name: r'review',
    required: true,
    includeIfNull: true,
  )


  final String? review;



  @JsonKey(
    
    name: r'est_saving_year',
    required: true,
    includeIfNull: true,
  )


  final String? estSavingYear;



  @JsonKey(
    
    name: r'price_changes',
    required: true,
    includeIfNull: false,
  )


  final int priceChanges;



  @JsonKey(
    
    name: r'ends',
    required: true,
    includeIfNull: true,
  )


  final DateTime? ends;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FixedItemOut &&
      other.kind == kind &&
      other.id == id &&
      other.name == name &&
      other.monthly == monthly &&
      other.yearly == yearly &&
      other.review == review &&
      other.estSavingYear == estSavingYear &&
      other.priceChanges == priceChanges &&
      other.ends == ends &&
      other.categoryId == categoryId;

    @override
    int get hashCode =>
        kind.hashCode +
        id.hashCode +
        name.hashCode +
        monthly.hashCode +
        yearly.hashCode +
        (review == null ? 0 : review.hashCode) +
        (estSavingYear == null ? 0 : estSavingYear.hashCode) +
        priceChanges.hashCode +
        (ends == null ? 0 : ends.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode);

  factory FixedItemOut.fromJson(Map<String, dynamic> json) => _$FixedItemOutFromJson(json);

  Map<String, dynamic> toJson() => _$FixedItemOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum FixedItemOutKindEnum {
@JsonValue(r'recurrente')
recurrente(r'recurrente'),
@JsonValue(r'cuota')
cuota(r'cuota');

const FixedItemOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


