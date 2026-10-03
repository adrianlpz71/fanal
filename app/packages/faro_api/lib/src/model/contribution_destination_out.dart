//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'contribution_destination_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContributionDestinationOut {
  /// Returns a new [ContributionDestinationOut] instance.
  ContributionDestinationOut({

    required  this.key,

    required  this.label,

    required  this.kind,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ContributionDestinationOutKindEnum kind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContributionDestinationOut &&
      other.key == key &&
      other.label == label &&
      other.kind == kind;

    @override
    int get hashCode =>
        key.hashCode +
        label.hashCode +
        kind.hashCode;

  factory ContributionDestinationOut.fromJson(Map<String, dynamic> json) => _$ContributionDestinationOutFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionDestinationOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ContributionDestinationOutKindEnum {
@JsonValue(r'inversion')
inversion(r'inversion'),
@JsonValue(r'ahorro')
ahorro(r'ahorro');

const ContributionDestinationOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


