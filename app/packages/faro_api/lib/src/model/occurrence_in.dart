//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'occurrence_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OccurrenceIn {
  /// Returns a new [OccurrenceIn] instance.
  OccurrenceIn({

    required  this.date,

    required  this.action,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'action',
    required: true,
    includeIfNull: false,
  )


  final OccurrenceInActionEnum action;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OccurrenceIn &&
      other.date == date &&
      other.action == action;

    @override
    int get hashCode =>
        date.hashCode +
        action.hashCode;

  factory OccurrenceIn.fromJson(Map<String, dynamic> json) => _$OccurrenceInFromJson(json);

  Map<String, dynamic> toJson() => _$OccurrenceInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum OccurrenceInActionEnum {
@JsonValue(r'editar')
editar(r'editar'),
@JsonValue(r'saltar')
saltar(r'saltar');

const OccurrenceInActionEnum(this.value);

final String value;

@override
String toString() => value;
}


