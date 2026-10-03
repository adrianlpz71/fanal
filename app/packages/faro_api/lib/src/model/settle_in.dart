//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'settle_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SettleIn {
  /// Returns a new [SettleIn] instance.
  SettleIn({

     this.createMovement = true,

     this.movementId,

     this.date,
  });

      /// Crear el movimiento de reembolso (Bizum recibido/enviado)
  @JsonKey(
    defaultValue: true,
    name: r'create_movement',
    required: false,
    includeIfNull: false,
  )


  final bool? createMovement;



  @JsonKey(
    
    name: r'movement_id',
    required: false,
    includeIfNull: false,
  )


  final String? movementId;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SettleIn &&
      other.createMovement == createMovement &&
      other.movementId == movementId &&
      other.date == date;

    @override
    int get hashCode =>
        createMovement.hashCode +
        (movementId == null ? 0 : movementId.hashCode) +
        (date == null ? 0 : date.hashCode);

  factory SettleIn.fromJson(Map<String, dynamic> json) => _$SettleInFromJson(json);

  Map<String, dynamic> toJson() => _$SettleInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

