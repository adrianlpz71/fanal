//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'bank_profile_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BankProfileIn {
  /// Returns a new [BankProfileIn] instance.
  BankProfileIn({

    required  this.name,

    required  this.mapping,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'mapping',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> mapping;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BankProfileIn &&
      other.name == name &&
      other.mapping == mapping;

    @override
    int get hashCode =>
        name.hashCode +
        mapping.hashCode;

  factory BankProfileIn.fromJson(Map<String, dynamic> json) => _$BankProfileInFromJson(json);

  Map<String, dynamic> toJson() => _$BankProfileInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

