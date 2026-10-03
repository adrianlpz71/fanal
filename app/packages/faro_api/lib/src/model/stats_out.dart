//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/top_concept_out.dart';
import 'package:faro_api/src/model/cycle_stats_out.dart';
import 'package:faro_api/src/model/category_stat_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stats_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StatsOut {
  /// Returns a new [StatsOut] instance.
  StatsOut({

    required  this.cycles,

    required  this.categories,

    required  this.topConcepts,

    required  this.avgSpend,

    required  this.avgSavingsRate,
  });

  @JsonKey(
    
    name: r'cycles',
    required: true,
    includeIfNull: false,
  )


  final List<CycleStatsOut> cycles;



  @JsonKey(
    
    name: r'categories',
    required: true,
    includeIfNull: false,
  )


  final List<CategoryStatOut> categories;



  @JsonKey(
    
    name: r'top_concepts',
    required: true,
    includeIfNull: false,
  )


  final List<TopConceptOut> topConcepts;



  @JsonKey(
    
    name: r'avg_spend',
    required: true,
    includeIfNull: false,
  )


  final String avgSpend;



  @JsonKey(
    
    name: r'avg_savings_rate',
    required: true,
    includeIfNull: true,
  )


  final String? avgSavingsRate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StatsOut &&
      other.cycles == cycles &&
      other.categories == categories &&
      other.topConcepts == topConcepts &&
      other.avgSpend == avgSpend &&
      other.avgSavingsRate == avgSavingsRate;

    @override
    int get hashCode =>
        cycles.hashCode +
        categories.hashCode +
        topConcepts.hashCode +
        avgSpend.hashCode +
        (avgSavingsRate == null ? 0 : avgSavingsRate.hashCode);

  factory StatsOut.fromJson(Map<String, dynamic> json) => _$StatsOutFromJson(json);

  Map<String, dynamic> toJson() => _$StatsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

