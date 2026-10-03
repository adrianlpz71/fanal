//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'platform_op_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformOpOut {
  /// Returns a new [PlatformOpOut] instance.
  PlatformOpOut({

    required  this.row,

    required  this.date,

    required  this.kind,

    required  this.key,

    required  this.assetName,

    required  this.units,

    required  this.amount,

    required  this.outcome,

    required  this.note,
  });

  @JsonKey(
    
    name: r'row',
    required: true,
    includeIfNull: false,
  )


  final int row;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PlatformOpOutKindEnum kind;



  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'asset_name',
    required: true,
    includeIfNull: false,
  )


  final String assetName;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'outcome',
    required: true,
    includeIfNull: false,
  )


  final PlatformOpOutOutcomeEnum outcome;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: true,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformOpOut &&
      other.row == row &&
      other.date == date &&
      other.kind == kind &&
      other.key == key &&
      other.assetName == assetName &&
      other.units == units &&
      other.amount == amount &&
      other.outcome == outcome &&
      other.note == note;

    @override
    int get hashCode =>
        row.hashCode +
        date.hashCode +
        kind.hashCode +
        key.hashCode +
        assetName.hashCode +
        units.hashCode +
        amount.hashCode +
        outcome.hashCode +
        (note == null ? 0 : note.hashCode);

  factory PlatformOpOut.fromJson(Map<String, dynamic> json) => _$PlatformOpOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformOpOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PlatformOpOutKindEnum {
@JsonValue(r'posicion_inicial')
posicionInicial(r'posicion_inicial'),
@JsonValue(r'compra')
compra(r'compra'),
@JsonValue(r'venta')
venta(r'venta'),
@JsonValue(r'aportacion_periodica')
aportacionPeriodica(r'aportacion_periodica'),
@JsonValue(r'traspaso_salida')
traspasoSalida(r'traspaso_salida'),
@JsonValue(r'traspaso_entrada')
traspasoEntrada(r'traspaso_entrada'),
@JsonValue(r'dividendo')
dividendo(r'dividendo'),
@JsonValue(r'interes')
interes(r'interes'),
@JsonValue(r'comision')
comision(r'comision'),
@JsonValue(r'recompensa')
recompensa(r'recompensa');

const PlatformOpOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PlatformOpOutOutcomeEnum {
@JsonValue(r'new')
new_(r'new'),
@JsonValue(r'duplicate')
duplicate(r'duplicate'),
@JsonValue(r'complete_pending')
completePending(r'complete_pending');

const PlatformOpOutOutcomeEnum(this.value);

final String value;

@override
String toString() => value;
}


