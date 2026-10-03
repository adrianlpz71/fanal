//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'share_brief_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareBriefOut {
  /// Returns a new [ShareBriefOut] instance.
  ShareBriefOut({

    required  this.id,

    required  this.personName,

    required  this.amount,

    required  this.direction,

    required  this.status,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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


  final ShareBriefOutDirectionEnum direction;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ShareBriefOutStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareBriefOut &&
      other.id == id &&
      other.personName == personName &&
      other.amount == amount &&
      other.direction == direction &&
      other.status == status;

    @override
    int get hashCode =>
        id.hashCode +
        personName.hashCode +
        amount.hashCode +
        direction.hashCode +
        status.hashCode;

  factory ShareBriefOut.fromJson(Map<String, dynamic> json) => _$ShareBriefOutFromJson(json);

  Map<String, dynamic> toJson() => _$ShareBriefOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareBriefOutDirectionEnum {
@JsonValue(r'me_deben')
meDeben(r'me_deben'),
@JsonValue(r'debo')
debo(r'debo');

const ShareBriefOutDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ShareBriefOutStatusEnum {
@JsonValue(r'pendiente')
pendiente(r'pendiente'),
@JsonValue(r'saldada')
saldada(r'saldada');

const ShareBriefOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


