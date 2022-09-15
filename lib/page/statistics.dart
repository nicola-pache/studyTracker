import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:untitled/bar_chart.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:untitled/page/timer.dart';


/// List of modules as stateful widget, part 1
/// Creates the state for the statistics widget.
class Statistics extends StatefulWidget {
  Statistics({Key? key}) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();

  /// Notifies all relevant widgets that the statistic needs to be rebuild
  static final ValueNotifier<bool> rebuildStatistic = ValueNotifier(false);

  /// Notifies all relevant widgets that the daily overview needs to be rebuild
  static final ValueNotifier<bool> rebuildDayOverview = ValueNotifier(false);
}

/// List of modules as stateful widget, part 2
/// The widget displays a bar graph statistic of the recorded time spent
/// studying.
class _StatisticsState extends State<Statistics> {

  /// List that will contain the data for the selected week.
  List<BarChart> data = [];

  /// Graph interval
  double range = 0.0;

  /// Current day
  DateTime _now = DateTime.now();

  /// List that will contain the data for the selected day in the graph.
  List selectedDatum = [];

  /// Initializes the statistic.
  /// When opening the statistic the selected week will be the current week.
  @override
  void initState() {
    super.initState();

    //Adds the data of the current week.
    _addData();
  }

  /// Adds weekdays and their data to [data].
  ///
  /// If there is no recorded [timeLearned] for a day, this day will be
  /// added with zero hours learned.
  void _addData() {
    DateTime _today = DateTime.utc(_now.year, _now.month, _now.day);
    DateTime _nextSunday = _today.add(Duration(days: 7 - _today.weekday));
    int _daysToMonday = 6;
    while (_daysToMonday >= 0) {
      DateTime _currentDate = _nextSunday.subtract(Duration(days: _daysToMonday));
      String _key = _currentDate.toString();
      String _day = "";
      double hoursLearnedDay = 0.0;
      if (_currentDate.weekday == 1) {
        _day = "Mo";
      } else if (_currentDate.weekday == 2) {
        _day = "Di";
      } else if (_currentDate.weekday == 3) {
        _day = "Mi";
      } else if (_currentDate.weekday == 4) {
        _day = "Do";
      } else if (_currentDate.weekday == 5) {
        _day = "Fr";
      } else if (_currentDate.weekday == 6) {
        _day = "Sa";
      } else if (_currentDate.weekday == 7) {
        _day = "So";
      }
      if (statisticsBox.containsKey(_key)) {
        statisticsBox.get(_key).forEach((moduleId, timeLearned) {
          Module module = Hive.box<Module>('modules').get(moduleId)!;
          double hoursLearned = timeLearned.inMinutes / 60;
          // Add bar charts with all relevant data
          data.add(BarChart(day: _day,
              hoursLearned: hoursLearned,
              barColor: charts.ColorUtil.fromDartColor(module.color),
              module: module.name));
          // Add up all the hours learned of the day
          hoursLearnedDay += hoursLearned;
        });

      } else {
        data.add(BarChart(day: _day, hoursLearned: 0,
            barColor: charts.ColorUtil.fromDartColor(Colors.white), module: ''));
      }
      // Set the new range if the hours learned in that day are greater
      if (hoursLearnedDay > range) {
        range = hoursLearnedDay;
      }
      _daysToMonday --;
    }

  }

  /// Changes the selected week to the week before the currently selected week.
  void changeToWeekBefore() {
    data.clear();
    range = 0.0;
    _now = _now.subtract(Duration(days: 7));
    _addData();
    Statistics.rebuildStatistic.value = !Statistics.rebuildStatistic.value;
    selectedDatum = [];
  }

  /// Changes the selected week to the week after the currently selected week.
  void changeToWeekAfter() {
    data.clear();
    range = 0.0;
    _now = _now.add(Duration(days: 7));
    _addData();
    Statistics.rebuildStatistic.value = !Statistics.rebuildStatistic.value;
    selectedDatum = [];
  }

  /// Checks if the selected week is the current week.
  bool _isCurrentWeek() {
    DateTime _currentDay = DateTime.now();
    DateTime _comparisonDate = DateTime.utc(_currentDay.year, _currentDay.month, _currentDay.day);
    DateTime _today = DateTime.utc(_now.year, _now.month, _now.day);
    return _today == _comparisonDate;
  }

  /// Returns a formatted date for the currently selected week.
  String giveWeek() {
    DateTime _today = DateTime.utc(_now.year, _now.month, _now.day);
    DateTime _sunday = _today.add(Duration(days: 7 - _today.weekday));
    DateTime _monday = _sunday.subtract(Duration(days: 6));
    String _mondayTextFormat = (DateFormat.y().format(_monday) == DateFormat.y().format(_sunday))
        ? DateFormat.d().format(_monday) + "." + DateFormat.M().format(_monday) + "."
        : DateFormat.d().format(_monday) + "." + DateFormat.M().format(_monday) + "." + DateFormat.y().format(_monday);
    String _sundayTextFormat = DateFormat.d().format(_sunday) + "." + DateFormat.M().format(_sunday) + "." + DateFormat.y().format(_sunday);
    return _mondayTextFormat + "  -  " + _sundayTextFormat;
  }

  /// Fills [selectedDatum] with the data of the new selected bars.
  void _onSelectionChanged(charts.SelectionModel model) {
    selectedDatum.clear();
    for (charts.SeriesDatum datum in model.selectedDatum) {
      selectedDatum.add([
        charts.ColorUtil.toDartColor(
            model.selectedSeries[0].data[datum.index!].barColor),
        model.selectedSeries[0].data[datum.index!].hoursLearned,
        model.selectedSeries[0].data[datum.index!].module
      ]);
    }
    Statistics.rebuildDayOverview.value = !Statistics.rebuildDayOverview.value;
  }

  /// Returns the number of bars for a selected day.
  int giveNumberOfBars() {
    int numberOfBars = selectedDatum.length;
    if (selectedDatum.isEmpty) {
      numberOfBars = 0;
    } else if (selectedDatum[0][1] == 0.0) {
      numberOfBars = 0;
    }
    return numberOfBars;
  }

  /// Returns a formatted String of the time spent learning for the selected day.
  String giveTimeLearned(int index) {
    double minutes = selectedDatum[index][1] * 60;
    int minutesLearned = minutes.toInt();
    String? timeLearned;
    int hoursLearned = ((minutesLearned / 60) - (minutesLearned % 1)).toInt();
    String hourCase = hoursLearned == 1
        ? " Stunde "
        : " Stunden ";
    String minuteCase = (minutesLearned % 60) == 1
        ? " Minute"
        : " Minuten";
    if (minutesLearned >= 60) {
      if (minutesLearned % 60 == 0) {
        timeLearned = hoursLearned.toString() + hourCase;
      } else {
        timeLearned = hoursLearned.toString() + hourCase
            + (minutesLearned % 60).toString() + minuteCase;
      }
    } else {
      timeLearned = minutesLearned.toString() + minuteCase;
    }
    return timeLearned;
  }

  /// Lists all the ticks from 0 to the range of the week with an interval of 0.5
  List<charts.TickSpec<double>> _listTicks() {
    double _interval = Hive.box('settings').get('statisticInterval');
    List<charts.TickSpec<double>> _ticks = [];
    if (range != 0.0) {
      for (double number = 0; number <= range + _interval; number += _interval) {
        _ticks.add(charts.TickSpec(number));
      }
    }
    return _ticks;
  }

  /// Builds the statistic.
  /// The body contains arrows to change the selected week, the bar graph for
  /// the selected week, and the detailed account of the data for a day upon
  /// selection.
  @override
  Widget build(BuildContext context) {

    charts.LineStyleSpec _lineStyleDomain = charts.LineStyleSpec(
        color: charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.onSurface));

    charts.LineStyleSpec _lineStyle = charts.LineStyleSpec(
        dashPattern: [4,4],
        color: charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6)));

    charts.TextStyleSpec _labelStyle = charts.TextStyleSpec(
        fontSize: Theme.of(context).textTheme.bodyText1?.fontSize?.toInt(),
        color: charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.onSurface));

    return Scaffold(
        appBar: AppBar(title: const Text('Statistik')),
        body: ValueListenableBuilder(
            valueListenable: Statistics.rebuildStatistic,
            builder: (context, value, widget) {
              List<charts.Series<BarChart, String>> series = [
                charts.Series(
                    id: "Gelernte Stunden",
                    data: data,
                    domainFn: (BarChart series, _) => series.day!,
                    measureFn: (BarChart series, _) => series.hoursLearned,
                    colorFn: (BarChart series, _) => series.barColor!)
              ];
              Color _buttonColor = _isCurrentWeek()
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary;
              return /**SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: **/Column(children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  height: 380,
                  padding: EdgeInsets.all(10),
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(children: <Widget>[
                            Row(children: <Widget>[
                              IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, semanticLabel: "Eine Woche zurück.",),
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () => {changeToWeekBefore()}),
                              Text(
                                giveWeek(),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, semanticLabel: "Eine Woche weiter.",),
                                  color: _buttonColor,
                                  onPressed: () {
                                    if (_isCurrentWeek()) {
                                      return null;
                                    } else {
                                      return changeToWeekAfter();
                                    }
                                  }),
                            ]),
                            Expanded(
                                child: Semantics(
                                    label: "Ein Balkendiagramm zeigt die Summe der gelernten Zeit für die ausgewählte Woche.",
                                    child: charts.BarChart(
                                      series,
                                      animate: true,
                                      // specifies line color of domain axis
                                      domainAxis: charts.OrdinalAxisSpec(
                                          renderSpec: charts.SmallTickRendererSpec(
                                              lineStyle: _lineStyleDomain,
                                              labelStyle: _labelStyle)),
                                      // specifies line color of measure axis
                                      primaryMeasureAxis: charts.NumericAxisSpec(
                                          tickProviderSpec:
                                          charts.StaticNumericTickProviderSpec(
                                              _listTicks()
                                          ),
                                          renderSpec: charts.GridlineRendererSpec(
                                              lineStyle: _lineStyle,
                                              labelStyle: _labelStyle)),
                                      barGroupingType: charts.BarGroupingType.stacked,
                                      selectionModels: [
                                        charts.SelectionModelConfig(
                                          type: charts.SelectionModelType.info,
                                          changedListener: _onSelectionChanged,
                                        )
                                      ],
                                    ))),
                          ]))),
                ),
                Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: Statistics.rebuildDayOverview,
                        builder: (context, value, _) {
                          return Container(
                              padding: EdgeInsets.all(10.0),
                              child: ListView.builder(
                                  itemCount: giveNumberOfBars(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 12.0,
                                                    color: selectedDatum[index][0]
                                                ))),
                                        child: ListTile(
                                            onTap: null,
                                            title: Text(
                                                '${selectedDatum[index][2]}: '
                                                    '${giveTimeLearned(index)}')));
                                  }));
                        })),
              ])/**))**/;
            }));
  }
}
