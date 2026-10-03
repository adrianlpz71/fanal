//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'person_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PersonIn {
  /// Returns a new [PersonIn] instance.
  PersonIn({

    required  this.name,

     this.notes,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PersonIn &&
      other.name == name &&
      other.notes == notes;

    @override
    int get hashCode =>
        name.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory PersonIn.fromJson(Map<String, dynamic> json) => _$PersonInFromJson(json);

  Map<String, dynamic> toJson() => _$PersonInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

