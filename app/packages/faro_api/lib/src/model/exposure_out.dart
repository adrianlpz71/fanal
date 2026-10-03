//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/exposure_item_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exposure_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExposureOut {
  /// Returns a new [ExposureOut] instance.
  ExposureOut({

    required  this.tipo,

    required  this.plataforma,

    required  this.sector,

    required  this.region,

    required  this.pais,

    required  this.divisa,
  });

  @JsonKey(
    
    name: r'tipo',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> tipo;



  @JsonKey(
    
    name: r'plataforma',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> plataforma;



  @JsonKey(
    
    name: r'sector',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> sector;



  @JsonKey(
    
    name: r'region',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> region;



  @JsonKey(
    
    name: r'pais',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> pais;



  @JsonKey(
    
    name: r'divisa',
    required: true,
    includeIfNull: false,
  )


  final List<ExposureItemOut> divisa;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExposureOut &&
      other.tipo == tipo &&
      other.plataforma == plataforma &&
      other.sector == sector &&
      other.region == region &&
      other.pais == pais &&
      other.divisa == divisa;

    @override
    int get hashCode =>
        tipo.hashCode +
        plataforma.hashCode +
        sector.hashCode +
        region.hashCode +
        pais.hashCode +
        divisa.hashCode;

  factory ExposureOut.fromJson(Map<String, dynamic> json) => _$ExposureOutFromJson(json);

  Map<String, dynamic> toJson() => _$ExposureOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

