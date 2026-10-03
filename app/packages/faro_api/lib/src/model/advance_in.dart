//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'advance_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdvanceIn {
  /// Returns a new [AdvanceIn] instance.
  AdvanceIn({

     this.merge = true,
  });

      /// Agrupar las cuotas pendientes en un cargo
  @JsonKey(
    defaultValue: true,
    name: r'merge',
    required: false,
    includeIfNull: false,
  )


  final bool? merge;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdvanceIn &&
      other.merge == merge;

    @override
    int get hashCode =>
        merge.hashCode;

  factory AdvanceIn.fromJson(Map<String, dynamic> json) => _$AdvanceInFromJson(json);

  Map<String, dynamic> toJson() => _$AdvanceInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

