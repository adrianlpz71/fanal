//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'share_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareIn {
  /// Returns a new [ShareIn] instance.
  ShareIn({

     this.personId,

     this.personName,

    required  this.amount,

     this.direction,
  });

  @JsonKey(
    
    name: r'person_id',
    required: false,
    includeIfNull: false,
  )


  final String? personId;



  @JsonKey(
    
    name: r'person_name',
    required: false,
    includeIfNull: false,
  )


  final String? personName;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'direction',
    required: false,
    includeIfNull: false,
  )


  final ShareInDirectionEnum? direction;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareIn &&
      other.personId == personId &&
      other.personName == personName &&
      other.amount == amount &&
      other.direction == direction;

    @override
    int get hashCode =>
        (personId == null ? 0 : personId.hashCode) +
        (personName == null ? 0 : personName.hashCode) +
        amount.hashCode +
        direction.hashCode;

  factory ShareIn.fromJson(Map<String, dynamic> json) => _$ShareInFromJson(json);

  Map<String, dynamic> toJson() => _$ShareInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareInDirectionEnum {
@JsonValue(r'me_deben')
meDeben(r'me_deben'),
@JsonValue(r'debo')
debo(r'debo');

const ShareInDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}


