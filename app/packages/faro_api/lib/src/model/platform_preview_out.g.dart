// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_preview_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformPreviewOut _$PlatformPreviewOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlatformPreviewOut', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'source',
      'platform',
      'counts',
      'warnings',
      'ops',
      'create_assets',
      'positions',
    ],
  );
  final val = PlatformPreviewOut(
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(_$PlatformPreviewOutSource_EnumEnumMap, v),
    ),
    platform: $checkedConvert('platform', (v) => v as String),
    counts: $checkedConvert('counts', (v) => Map<String, int>.from(v as Map)),
    warnings: $checkedConvert(
      'warnings',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    ops: $checkedConvert(
      'ops',
      (v) => (v as List<dynamic>)
          .map((e) => PlatformOpOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    createAssets: $checkedConvert(
      'create_assets',
      (v) => (v as List<dynamic>)
          .map((e) => NewAssetOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    positions: $checkedConvert(
      'positions',
      (v) => (v as List<dynamic>)
          .map((e) => PlatformPositionOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source', 'createAssets': 'create_assets'});

Map<String, dynamic> _$PlatformPreviewOutToJson(PlatformPreviewOut instance) =>
    <String, dynamic>{
      'source': _$PlatformPreviewOutSource_EnumEnumMap[instance.source_]!,
      'platform': instance.platform,
      'counts': instance.counts,
      'warnings': instance.warnings,
      'ops': instance.ops.map((e) => e.toJson()).toList(),
      'create_assets': instance.createAssets.map((e) => e.toJson()).toList(),
      'positions': instance.positions.map((e) => e.toJson()).toList(),
    };

const _$PlatformPreviewOutSource_EnumEnumMap = {
  PlatformPreviewOutSource_Enum.myinvestor: 'myinvestor',
  PlatformPreviewOutSource_Enum.neverless: 'neverless',
  PlatformPreviewOutSource_Enum.generic: 'generic',
};
