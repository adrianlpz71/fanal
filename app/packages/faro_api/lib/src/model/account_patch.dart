//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountPatch {
  /// Returns a new [AccountPatch] instance.
  AccountPatch({

     this.name,

     this.bank,

     this.archived,

     this.apy,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'bank',
    required: false,
    includeIfNull: false,
  )


  final String? bank;



  @JsonKey(
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;



  @JsonKey(
    
    name: r'apy',
    required: false,
    includeIfNull: false,
  )


  final String? apy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountPatch &&
      other.name == name &&
      other.bank == bank &&
      other.archived == archived &&
      other.apy == apy;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        (bank == null ? 0 : bank.hashCode) +
        (archived == null ? 0 : archived.hashCode) +
        (apy == null ? 0 : apy.hashCode);

  factory AccountPatch.fromJson(Map<String, dynamic> json) => _$AccountPatchFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

