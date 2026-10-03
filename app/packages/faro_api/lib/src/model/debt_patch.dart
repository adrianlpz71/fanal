//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'debt_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DebtPatch {
  /// Returns a new [DebtPatch] instance.
  DebtPatch({

     this.name,

     this.notes,

     this.interestRate,
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
    
    name: r'interest_rate',
    required: false,
    includeIfNull: false,
  )


  final String? interestRate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DebtPatch &&
      other.name == name &&
      other.notes == notes &&
      other.interestRate == interestRate;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (interestRate == null ? 0 : interestRate.hashCode);

  factory DebtPatch.fromJson(Map<String, dynamic> json) => _$DebtPatchFromJson(json);

  Map<String, dynamic> toJson() => _$DebtPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

