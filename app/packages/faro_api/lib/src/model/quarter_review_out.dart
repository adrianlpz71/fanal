//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/quarter_metrics_out.dart';
import 'package:faro_api/src/model/category_rise_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quarter_review_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuarterReviewOut {
  /// Returns a new [QuarterReviewOut] instance.
  QuarterReviewOut({

    required  this.quarter,

    required  this.label,

    required  this.start,

    required  this.end,

    required  this.inProgress,

    required  this.metrics,

    required  this.previous,

    required  this.previousLabel,

    required  this.rising,

    required  this.changed,

    required  this.nextSteps,

    required  this.savedAt,
  });

  @JsonKey(
    
    name: r'quarter',
    required: true,
    includeIfNull: false,
  )


  final String quarter;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: false,
  )


  final DateTime start;



  @JsonKey(
    
    name: r'end',
    required: true,
    includeIfNull: false,
  )


  final DateTime end;



  @JsonKey(
    
    name: r'in_progress',
    required: true,
    includeIfNull: false,
  )


  final bool inProgress;



  @JsonKey(
    
    name: r'metrics',
    required: true,
    includeIfNull: false,
  )


  final QuarterMetricsOut metrics;



  @JsonKey(
    
    name: r'previous',
    required: true,
    includeIfNull: true,
  )


  final QuarterMetricsOut? previous;



  @JsonKey(
    
    name: r'previous_label',
    required: true,
    includeIfNull: false,
  )


  final String previousLabel;



  @JsonKey(
    
    name: r'rising',
    required: true,
    includeIfNull: false,
  )


  final List<CategoryRiseOut> rising;



  @JsonKey(
    
    name: r'changed',
    required: true,
    includeIfNull: false,
  )


  final String changed;



  @JsonKey(
    
    name: r'next_steps',
    required: true,
    includeIfNull: false,
  )


  final String nextSteps;



  @JsonKey(
    
    name: r'saved_at',
    required: true,
    includeIfNull: true,
  )


  final DateTime? savedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is QuarterReviewOut &&
      other.quarter == quarter &&
      other.label == label &&
      other.start == start &&
      other.end == end &&
      other.inProgress == inProgress &&
      other.metrics == metrics &&
      other.previous == previous &&
      other.previousLabel == previousLabel &&
      other.rising == rising &&
      other.changed == changed &&
      other.nextSteps == nextSteps &&
      other.savedAt == savedAt;

    @override
    int get hashCode =>
        quarter.hashCode +
        label.hashCode +
        start.hashCode +
        end.hashCode +
        inProgress.hashCode +
        metrics.hashCode +
        (previous == null ? 0 : previous.hashCode) +
        previousLabel.hashCode +
        rising.hashCode +
        changed.hashCode +
        nextSteps.hashCode +
        (savedAt == null ? 0 : savedAt.hashCode);

  factory QuarterReviewOut.fromJson(Map<String, dynamic> json) => _$QuarterReviewOutFromJson(json);

  Map<String, dynamic> toJson() => _$QuarterReviewOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

