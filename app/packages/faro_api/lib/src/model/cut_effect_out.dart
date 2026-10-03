//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'cut_effect_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CutEffectOut {
  /// Returns a new [CutEffectOut] instance.
  CutEffectOut({

    required  this.cut,

    required  this.fiAge,
  });

  @JsonKey(
    
    name: r'cut',
    required: true,
    includeIfNull: false,
  )


  final String cut;



  @JsonKey(
    
    name: r'fi_age',
    required: true,
    includeIfNull: true,
  )


  final String? fiAge;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CutEffectOut &&
      other.cut == cut &&
      other.fiAge == fiAge;

    @override
    int get hashCode =>
        cut.hashCode +
        (fiAge == null ? 0 : fiAge.hashCode);

  factory CutEffectOut.fromJson(Map<String, dynamic> json) => _$CutEffectOutFromJson(json);

  Map<String, dynamic> toJson() => _$CutEffectOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

