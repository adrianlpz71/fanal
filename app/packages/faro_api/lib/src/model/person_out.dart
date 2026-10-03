//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'person_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PersonOut {
  /// Returns a new [PersonOut] instance.
  PersonOut({

    required  this.id,

    required  this.name,

    required  this.notes,

    required  this.archived,

    required  this.owedToMe,

    required  this.iOwe,

    required  this.net,
  });

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
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;



  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;



  @JsonKey(
    
    name: r'owed_to_me',
    required: true,
    includeIfNull: false,
  )


  final String owedToMe;



  @JsonKey(
    
    name: r'i_owe',
    required: true,
    includeIfNull: false,
  )


  final String iOwe;



  @JsonKey(
    
    name: r'net',
    required: true,
    includeIfNull: false,
  )


  final String net;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PersonOut &&
      other.id == id &&
      other.name == name &&
      other.notes == notes &&
      other.archived == archived &&
      other.owedToMe == owedToMe &&
      other.iOwe == iOwe &&
      other.net == net;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        archived.hashCode +
        owedToMe.hashCode +
        iOwe.hashCode +
        net.hashCode;

  factory PersonOut.fromJson(Map<String, dynamic> json) => _$PersonOutFromJson(json);

  Map<String, dynamic> toJson() => _$PersonOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

