// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exposure_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExposureOut _$ExposureOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExposureOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'tipo',
          'plataforma',
          'sector',
          'region',
          'pais',
          'divisa',
        ],
      );
      final val = ExposureOut(
        tipo: $checkedConvert(
          'tipo',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        plataforma: $checkedConvert(
          'plataforma',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        sector: $checkedConvert(
          'sector',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        region: $checkedConvert(
          'region',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        pais: $checkedConvert(
          'pais',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        divisa: $checkedConvert(
          'divisa',
          (v) => (v as List<dynamic>)
              .map((e) => ExposureItemOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExposureOutToJson(ExposureOut instance) =>
    <String, dynamic>{
      'tipo': instance.tipo.map((e) => e.toJson()).toList(),
      'plataforma': instance.plataforma.map((e) => e.toJson()).toList(),
      'sector': instance.sector.map((e) => e.toJson()).toList(),
      'region': instance.region.map((e) => e.toJson()).toList(),
      'pais': instance.pais.map((e) => e.toJson()).toList(),
      'divisa': instance.divisa.map((e) => e.toJson()).toList(),
    };
