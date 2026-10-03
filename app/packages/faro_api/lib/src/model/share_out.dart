//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'share_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareOut {
  /// Returns a new [ShareOut] instance.
  ShareOut({

    required  this.id,

    required  this.movementId,

    required  this.personId,

    required  this.personName,

    required  this.amount,

    required  this.direction,

    required  this.status,

    required  this.settledByMovementId,

     this.movementConcept,

     this.movementDate,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: false,
  )


  final String movementId;



  @JsonKey(
    
    name: r'person_id',
    required: true,
    includeIfNull: false,
  )


  final String personId;



  @JsonKey(
    
    name: r'person_name',
    required: true,
    includeIfNull: false,
  )


  final String personName;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'direction',
    required: true,
    includeIfNull: false,
  )


  final ShareOutDirectionEnum direction;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ShareOutStatusEnum status;



  @JsonKey(
    
    name: r'settled_by_movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? settledByMovementId;



  @JsonKey(
    
    name: r'movement_concept',
    required: false,
    includeIfNull: false,
  )


  final String? movementConcept;



  @JsonKey(
    
    name: r'movement_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? movementDate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareOut &&
      other.id == id &&
      other.movementId == movementId &&
      other.personId == personId &&
      other.personName == personName &&
      other.amount == amount &&
      other.direction == direction &&
      other.status == status &&
      other.settledByMovementId == settledByMovementId &&
      other.movementConcept == movementConcept &&
      other.movementDate == movementDate;

    @override
    int get hashCode =>
        id.hashCode +
        movementId.hashCode +
        personId.hashCode +
        personName.hashCode +
        amount.hashCode +
        direction.hashCode +
        status.hashCode +
        (settledByMovementId == null ? 0 : settledByMovementId.hashCode) +
        (movementConcept == null ? 0 : movementConcept.hashCode) +
        (movementDate == null ? 0 : movementDate.hashCode);

  factory ShareOut.fromJson(Map<String, dynamic> json) => _$ShareOutFromJson(json);

  Map<String, dynamic> toJson() => _$ShareOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareOutDirectionEnum {
@JsonValue(r'me_deben')
meDeben(r'me_deben'),
@JsonValue(r'debo')
debo(r'debo');

const ShareOutDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ShareOutStatusEnum {
@JsonValue(r'pendiente')
pendiente(r'pendiente'),
@JsonValue(r'saldada')
saldada(r'saldada');

const ShareOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


