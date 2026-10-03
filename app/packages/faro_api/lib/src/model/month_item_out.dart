//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/movement_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'month_item_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MonthItemOut {
  /// Returns a new [MonthItemOut] instance.
  MonthItemOut({

    required  this.kind,

    required  this.date,

    required  this.concept,

    required  this.amount,

    required  this.categoryId,

    required  this.source_,

    required  this.movement,

    required  this.templateId,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final MonthItemOutKindEnum kind;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'movement',
    required: true,
    includeIfNull: true,
  )


  final MovementOut? movement;



  @JsonKey(
    
    name: r'template_id',
    required: true,
    includeIfNull: true,
  )


  final String? templateId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MonthItemOut &&
      other.kind == kind &&
      other.date == date &&
      other.concept == concept &&
      other.amount == amount &&
      other.categoryId == categoryId &&
      other.source_ == source_ &&
      other.movement == movement &&
      other.templateId == templateId;

    @override
    int get hashCode =>
        kind.hashCode +
        date.hashCode +
        concept.hashCode +
        amount.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        source_.hashCode +
        (movement == null ? 0 : movement.hashCode) +
        (templateId == null ? 0 : templateId.hashCode);

  factory MonthItemOut.fromJson(Map<String, dynamic> json) => _$MonthItemOutFromJson(json);

  Map<String, dynamic> toJson() => _$MonthItemOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MonthItemOutKindEnum {
@JsonValue(r'movimiento')
movimiento(r'movimiento'),
@JsonValue(r'recurrente')
recurrente(r'recurrente');

const MonthItemOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


