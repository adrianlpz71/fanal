//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tx_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TxIn {
  /// Returns a new [TxIn] instance.
  TxIn({

     this.id,

    required  this.assetId,

    required  this.kind,

    required  this.tradeDate,

     this.amountEur = '0',

     this.units,

     this.price,

     this.avgCost,

     this.fee = '0',

     this.pending = false,

     this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final TxInKindEnum kind;



  @JsonKey(
    
    name: r'trade_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime tradeDate;



  @JsonKey(
    defaultValue: '0',
    name: r'amount_eur',
    required: false,
    includeIfNull: false,
  )


  final String? amountEur;



  @JsonKey(
    
    name: r'units',
    required: false,
    includeIfNull: false,
  )


  final String? units;



  @JsonKey(
    
    name: r'price',
    required: false,
    includeIfNull: false,
  )


  final String? price;



  @JsonKey(
    
    name: r'avg_cost',
    required: false,
    includeIfNull: false,
  )


  final String? avgCost;



  @JsonKey(
    defaultValue: '0',
    name: r'fee',
    required: false,
    includeIfNull: false,
  )


  final String? fee;



      /// Aportación pendiente de valor liquidativo
  @JsonKey(
    defaultValue: false,
    name: r'pending',
    required: false,
    includeIfNull: false,
  )


  final bool? pending;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TxIn &&
      other.id == id &&
      other.assetId == assetId &&
      other.kind == kind &&
      other.tradeDate == tradeDate &&
      other.amountEur == amountEur &&
      other.units == units &&
      other.price == price &&
      other.avgCost == avgCost &&
      other.fee == fee &&
      other.pending == pending &&
      other.notes == notes;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        assetId.hashCode +
        kind.hashCode +
        tradeDate.hashCode +
        amountEur.hashCode +
        (units == null ? 0 : units.hashCode) +
        (price == null ? 0 : price.hashCode) +
        (avgCost == null ? 0 : avgCost.hashCode) +
        fee.hashCode +
        pending.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory TxIn.fromJson(Map<String, dynamic> json) => _$TxInFromJson(json);

  Map<String, dynamic> toJson() => _$TxInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum TxInKindEnum {
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

const TxInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


