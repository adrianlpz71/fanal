//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tx_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TxOut {
  /// Returns a new [TxOut] instance.
  TxOut({

    required  this.id,

    required  this.assetId,

    required  this.kind,

    required  this.status,

    required  this.tradeDate,

    required  this.settleDate,

    required  this.amountEur,

    required  this.units,

    required  this.price,

    required  this.avgCost,

    required  this.fee,

    required  this.pairId,

    required  this.movementId,

    required  this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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


  final TxOutKindEnum kind;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final TxOutStatusEnum status;



  @JsonKey(
    
    name: r'trade_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime tradeDate;



  @JsonKey(
    
    name: r'settle_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? settleDate;



  @JsonKey(
    
    name: r'amount_eur',
    required: true,
    includeIfNull: false,
  )


  final String amountEur;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: true,
  )


  final String? units;



  @JsonKey(
    
    name: r'price',
    required: true,
    includeIfNull: true,
  )


  final String? price;



  @JsonKey(
    
    name: r'avg_cost',
    required: true,
    includeIfNull: true,
  )


  final String? avgCost;



  @JsonKey(
    
    name: r'fee',
    required: true,
    includeIfNull: false,
  )


  final String fee;



  @JsonKey(
    
    name: r'pair_id',
    required: true,
    includeIfNull: true,
  )


  final String? pairId;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? movementId;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TxOut &&
      other.id == id &&
      other.assetId == assetId &&
      other.kind == kind &&
      other.status == status &&
      other.tradeDate == tradeDate &&
      other.settleDate == settleDate &&
      other.amountEur == amountEur &&
      other.units == units &&
      other.price == price &&
      other.avgCost == avgCost &&
      other.fee == fee &&
      other.pairId == pairId &&
      other.movementId == movementId &&
      other.notes == notes;

    @override
    int get hashCode =>
        id.hashCode +
        assetId.hashCode +
        kind.hashCode +
        status.hashCode +
        tradeDate.hashCode +
        (settleDate == null ? 0 : settleDate.hashCode) +
        amountEur.hashCode +
        (units == null ? 0 : units.hashCode) +
        (price == null ? 0 : price.hashCode) +
        (avgCost == null ? 0 : avgCost.hashCode) +
        fee.hashCode +
        (pairId == null ? 0 : pairId.hashCode) +
        (movementId == null ? 0 : movementId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory TxOut.fromJson(Map<String, dynamic> json) => _$TxOutFromJson(json);

  Map<String, dynamic> toJson() => _$TxOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum TxOutKindEnum {
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

const TxOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum TxOutStatusEnum {
@JsonValue(r'pendiente_vl')
pendienteVl(r'pendiente_vl'),
@JsonValue(r'liquidada')
liquidada(r'liquidada'),
@JsonValue(r'cancelada')
cancelada(r'cancelada');

const TxOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


