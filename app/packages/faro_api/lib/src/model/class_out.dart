//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/asset_class_out.dart';
import 'package:faro_api/src/model/position_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'class_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClassOut {
  /// Returns a new [ClassOut] instance.
  ClassOut({

    required  this.assetClass,

    required  this.value,

    required  this.pending,

    required  this.weight,

    required  this.target,

    required  this.min,

    required  this.max,

    required  this.tolerancePp,

    required  this.status,

    required  this.positions,
  });

  @JsonKey(
    
    name: r'asset_class',
    required: true,
    includeIfNull: false,
  )


  final AssetClassOut assetClass;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final String pending;



  @JsonKey(
    
    name: r'weight',
    required: true,
    includeIfNull: false,
  )


  final String weight;



  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: true,
  )


  final String? target;



  @JsonKey(
    
    name: r'min',
    required: true,
    includeIfNull: true,
  )


  final String? min;



  @JsonKey(
    
    name: r'max',
    required: true,
    includeIfNull: true,
  )


  final String? max;



  @JsonKey(
    
    name: r'tolerance_pp',
    required: true,
    includeIfNull: false,
  )


  final String tolerancePp;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: true,
  )


  final ClassOutStatusEnum? status;



  @JsonKey(
    
    name: r'positions',
    required: true,
    includeIfNull: false,
  )


  final List<PositionOut> positions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ClassOut &&
      other.assetClass == assetClass &&
      other.value == value &&
      other.pending == pending &&
      other.weight == weight &&
      other.target == target &&
      other.min == min &&
      other.max == max &&
      other.tolerancePp == tolerancePp &&
      other.status == status &&
      other.positions == positions;

    @override
    int get hashCode =>
        assetClass.hashCode +
        value.hashCode +
        pending.hashCode +
        weight.hashCode +
        (target == null ? 0 : target.hashCode) +
        (min == null ? 0 : min.hashCode) +
        (max == null ? 0 : max.hashCode) +
        tolerancePp.hashCode +
        (status == null ? 0 : status.hashCode) +
        positions.hashCode;

  factory ClassOut.fromJson(Map<String, dynamic> json) => _$ClassOutFromJson(json);

  Map<String, dynamic> toJson() => _$ClassOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ClassOutStatusEnum {
@JsonValue(r'bajo')
bajo(r'bajo'),
@JsonValue(r'alto')
alto(r'alto'),
@JsonValue(r'ok')
ok(r'ok');

const ClassOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


