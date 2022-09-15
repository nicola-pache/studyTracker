import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

/// Class containing the [BarChart] object.
class BarChart {

  /// Day of the week
  final String? day;
  /// Amount of hours spent learning
  final double? hoursLearned;
  /// Color of the bar
  final charts.Color? barColor;
  /// Associated module
  final String? module;

  /// Defines the variables required by the bar chart.
  BarChart({
    @required this.day,
    @required this.hoursLearned,
    @required this.barColor,
    @required this.module
  });
}