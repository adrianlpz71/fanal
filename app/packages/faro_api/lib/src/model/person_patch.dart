//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'person_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PersonPatch {
  /// Returns a new [PersonPatch] instance.
  PersonPatch({

     this.name,

     this.notes,

     this.archived,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PersonPatch &&
      other.name == name &&
      other.notes == notes &&
      other.archived == archived;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (archived == null ? 0 : archived.hashCode);

  factory PersonPatch.fromJson(Map<String, dynamic> json) => _$PersonPatchFromJson(json);

  Map<String, dynamic> toJson() => _$PersonPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

