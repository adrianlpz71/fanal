//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'realized_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RealizedOut {
  /// Returns a new [RealizedOut] instance.
  RealizedOut({

    required  this.date,

    required  this.units,

    required  this.proceeds,

    required  this.gainFifo,

    required  this.gainPmp,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'proceeds',
    required: true,
    includeIfNull: false,
  )


  final String proceeds;



  @JsonKey(
    
    name: r'gain_fifo',
    required: true,
    includeIfNull: false,
  )


  final String gainFifo;



  @JsonKey(
    
    name: r'gain_pmp',
    required: true,
    includeIfNull: false,
  )


  final String gainPmp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RealizedOut &&
      other.date == date &&
      other.units == units &&
      other.proceeds == proceeds &&
      other.gainFifo == gainFifo &&
      other.gainPmp == gainPmp;

    @override
    int get hashCode =>
        date.hashCode +
        units.hashCode +
        proceeds.hashCode +
        gainFifo.hashCode +
        gainPmp.hashCode;

  factory RealizedOut.fromJson(Map<String, dynamic> json) => _$RealizedOutFromJson(json);

  Map<String, dynamic> toJson() => _$RealizedOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

