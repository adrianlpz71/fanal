//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'bank_profile_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BankProfileOut {
  /// Returns a new [BankProfileOut] instance.
  BankProfileOut({

    required  this.id,

    required  this.name,

    required  this.mapping,
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
    
    name: r'mapping',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> mapping;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BankProfileOut &&
      other.id == id &&
      other.name == name &&
      other.mapping == mapping;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        mapping.hashCode;

  factory BankProfileOut.fromJson(Map<String, dynamic> json) => _$BankProfileOutFromJson(json);

  Map<String, dynamic> toJson() => _$BankProfileOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

