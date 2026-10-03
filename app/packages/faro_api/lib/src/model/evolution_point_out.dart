//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'evolution_point_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EvolutionPointOut {
  /// Returns a new [EvolutionPointOut] instance.
  EvolutionPointOut({

    required  this.date,

    required  this.accounts,

    required  this.investments,

    required  this.contributed,

    required  this.pending,

    required  this.receivable,

    required  this.debts,

    required  this.installments,

    required  this.net,

    required  this.components,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'accounts',
    required: true,
    includeIfNull: false,
  )


  final String accounts;



  @JsonKey(
    
    name: r'investments',
    required: true,
    includeIfNull: false,
  )


  final String investments;



      /// Dinero puesto en inversiones hasta ese día
  @JsonKey(
    
    name: r'contributed',
    required: true,
    includeIfNull: false,
  )


  final String contributed;



      /// Pendiente de VL (solo el punto de hoy)
  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final String pending;



  @JsonKey(
    
    name: r'receivable',
    required: true,
    includeIfNull: false,
  )


  final String receivable;



  @JsonKey(
    
    name: r'debts',
    required: true,
    includeIfNull: false,
  )


  final String debts;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final String installments;



  @JsonKey(
    
    name: r'net',
    required: true,
    includeIfNull: false,
  )


  final String net;



  @JsonKey(
    
    name: r'components',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> components;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EvolutionPointOut &&
      other.date == date &&
      other.accounts == accounts &&
      other.investments == investments &&
      other.contributed == contributed &&
      other.pending == pending &&
      other.receivable == receivable &&
      other.debts == debts &&
      other.installments == installments &&
      other.net == net &&
      other.components == components;

    @override
    int get hashCode =>
        date.hashCode +
        accounts.hashCode +
        investments.hashCode +
        contributed.hashCode +
        pending.hashCode +
        receivable.hashCode +
        debts.hashCode +
        installments.hashCode +
        net.hashCode +
        components.hashCode;

  factory EvolutionPointOut.fromJson(Map<String, dynamic> json) => _$EvolutionPointOutFromJson(json);

  Map<String, dynamic> toJson() => _$EvolutionPointOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

