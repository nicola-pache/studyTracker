import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/page/timetable.dart';
import 'package:untitled/widget/custom_time_picker.dart';
import '../notification_services.dart';
import 'package:hive/hive.dart';

import '../onboarding.dart';

/// This class build the settings page.
class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  /// Reference to the settingsBox for easier access.
  static final Box settingsBox = Hive.box('settings');

  /// If the current theme of the app changes, the app will be reloaded.
  static final ValueNotifier<int> currentTheme =
      ValueNotifier<int>(settingsBox.get('theme'));

  /// Builds the contents of the settings page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Einstellungen')),
        body: ListView(
            padding: EdgeInsets.all(10.0),
            children: <Widget>[
              TimetableTimes(),
              SizedBox(height: 15),
              Checkbox(
                  title: 'Stundenplan-Veranstaltungen standardmäßig im Kalender'
                      ' anzeigen',
                  boxKey: 'showInCalendarDefault'),
              SizedBox(height: 15),
              StatisticInterval(),
              SizedBox(height: 15),
              ThreeRadioButtons(
                  title: 'Theme',
                  values: <String>['System', 'Hell', 'Dunkel'],
                  defaultValue: settingsBox.get('theme'),
                  onChanged: (int value) {
                    settingsBox.put('theme', value);
                    currentTheme.value = value;
                  }),
              const SizedBox(height: 15),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    const Text("Tutorial",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                        child: const Text("Tutorial erneut ansehen",
                            style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return const Onboarding();
                              }));
                        }
                    )
                  ]
              ),
              // Example notifications for testing notifications
              //ExampleNotification(),
            ]));
  }
}

/// A widget to show a checkbox.
class Checkbox extends StatelessWidget {
  const Checkbox({required this.title, required this.boxKey, Key? key})
      : super(key: key);
  final String title;
  final String boxKey;

  /// Builds the checkbox widget.
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return CheckboxListTile(
              contentPadding: const EdgeInsets.only(left: 5.0),
              title: Text(title,
                  style: const TextStyle(fontSize: 18)),
              controlAffinity: ListTileControlAffinity.leading,
              value: Hive.box('settings').get(boxKey),
              onChanged: (newValue) {
                Hive.box('settings').put(boxKey, newValue!);
                setState(() {});
              }
          );
        }
    );
  }
}

/// Widget for three radio buttons, part 1. Creates the state for the widget.
class ThreeRadioButtons extends StatefulWidget {
  const ThreeRadioButtons(
      {Key? key,
        required this.title,
        this.subtitle,
        required this.values,
        required this.defaultValue,
        required this.onChanged,
        this.disabledButtons = const []})
      : super(key: key);
  final String title;
  final String? subtitle;
  final List<String> values;
  final int defaultValue;
  final void Function(int) onChanged;
  final List<String> disabledButtons;

  @override
  State<ThreeRadioButtons> createState() => _ThreeRadioButtonsState();
}

/// Widget for three radio buttons, part 2. Handles the state of the widget.
class _ThreeRadioButtonsState extends State<ThreeRadioButtons> {

  /// The value of the currently selected radio button.
  late int _value;

  /// Initializes the widget.
  @override
  void initState() {
    _value = widget.defaultValue;
    super.initState();
  }

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text(widget.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (widget.subtitle != null)
        Text(widget.subtitle!, style: TextStyle(fontSize: 16)),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(children: [
            Radio<int>(
                visualDensity: VisualDensity(vertical: -4),
                value: 0,
                groupValue: _value,
                onChanged: widget.disabledButtons.contains(widget.values[0])
                    ? null
                    : (int? newValue) {
                  setState(() => _value = newValue!);
                  widget.onChanged(newValue!);
                }),
            Text(widget.values[0], style: TextStyle(fontSize: 18.0))
          ]),
          Row(children: [
            Radio<int>(
                visualDensity: VisualDensity(vertical: -4),
                value: 1,
                groupValue: _value,
                onChanged: widget.disabledButtons.contains(widget.values[1])
                    ? null
                    : (int? newValue) {
                  setState(() => _value = newValue!);
                  widget.onChanged(newValue!);
                }),
            Text(widget.values[1], style: TextStyle(fontSize: 18.0))
          ]),
          Row(children: [
            Radio<int>(
                visualDensity: VisualDensity(vertical: -4),
                value: 2,
                groupValue: _value,
                onChanged: widget.disabledButtons.contains(widget.values[2])
                    ? null
                    : (int? newValue) {
                  setState(() => _value = newValue!);
                  widget.onChanged(newValue!);
                }),
            Text(widget.values[2], style: TextStyle(fontSize: 18.0))
          ])
        ],
      )
    ]);
  }
}

/// Set times for the timetable, part 1. Creates the state for the widget.
class TimetableTimes extends StatefulWidget {
  const TimetableTimes({Key? key}) : super(key: key);

  @override
  _TimetableTimesState createState() => _TimetableTimesState();
}


/// Set times for the timetable, part 2. Handles the state of the widget.
class _TimetableTimesState extends State<TimetableTimes> {

  /// Currently selected start time.
  TimeOfDay _startTime = Hive.box('settings').get('timetableStart');

  /// Currently selected end time.
  TimeOfDay _endTime = Hive.box('settings').get('timetableEnd');

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Stundenplan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CustomTimePicker(
              label: "Tagesbeginn",
              labelLength: 135,
              title: "Beginn des Stundenplan-Tages",
              initialTime: _startTime,
              onChange: (pickedStartTime) {
                setState(() {
                  _startTime = pickedStartTime;
                  _endTime = _calculateNewEndTime(_endTime, _startTime);
                  Hive.box('settings').put('timetableStart', _startTime);
                  Hive.box('settings').put('timetableEnd', _endTime);
                  Timetable.timetableChanged.value =
                  !Timetable.timetableChanged.value;
                });
              }),
          CustomTimePicker(
              label: "Tagesende",
              labelLength: 135,
              title: "Ende des Stundenplan-Tages",
              initialTime: _endTime,
              onChange: (pickedEndTime) {
                setState(() {
                  _endTime = pickedEndTime;
                  Hive.box('settings').put('timetableEnd', _endTime);
                  Timetable.timetableChanged.value =
                  !Timetable.timetableChanged.value;
                });
              }),
          CustomTimePicker(
              label: "Veranstaltungs-Länge",
              labelLength: 135,
              title: "Länge einer Veranstaltung",
              initialTime: Hive.box('settings').get('timetableEventLength'),
              onChange: (pickedTime) {
                setState(() {
                  Hive.box('settings').put('timetableEventLength', pickedTime);
                });
              }),
        ]);
  }

  /// Calculates the new end time after a minimum distance from the start time.
  TimeOfDay _calculateNewEndTime(TimeOfDay end, TimeOfDay start) {
    TimeOfDay _newEndTime;
    int _minDistance = 60;
    int _endMinutes = end.hour * 60 + end.minute;
    int _startMinutes = start.hour * 60 + start.minute;
    if (_endMinutes - _startMinutes < _minDistance) {
      int _newEndTimeMinutes = _startMinutes + _minDistance;
      _newEndTime = TimeOfDay(hour: ((_newEndTimeMinutes) / 60).floor(),
          minute: (_newEndTimeMinutes) % 60);
    } else {
      _newEndTime = end;
    }
    return _newEndTime;
  }
}

/// This widget lets the user select an interval for the statistics chart.
class StatisticInterval extends StatelessWidget {
  StatisticInterval({Key? key}) : super(key: key);

  /// Available intervals.
  final List<double> _intervals = [0.25, 0.5, 1.0, 1.5, 2.0];

  /// A change in the interval reloads the widget.
  final ValueNotifier<double> _selectedInterval =
      ValueNotifier<double>(Hive.box('settings').get('statisticInterval'));

  /// List of the buttons the user can select.
  final List<Widget> _choiceChips = [];

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    if(_choiceChips.isEmpty) {
      for (int index = 0; index < _intervals.length; index++) {
        _choiceChips.addAll([
          ValueListenableBuilder(
            valueListenable: _selectedInterval,
            builder: (BuildContext context, double value, _) {
              return ChoiceChip(
                  padding: const EdgeInsets.all(10.0),
                  label: Text(_intervals[index].toString()),
                  selected: value == _intervals[index],
                  onSelected: (bool selected) {
                    Hive.box('settings').put(
                        'statisticInterval', _intervals[index]);
                    _selectedInterval.value = _intervals[index];
                  }
              );
            }),
          const SizedBox(width: 10.0)
        ]);
      }
    }
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Statistik-Intervall",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _choiceChips)
              )
            ]));
  }
}

/* ONLY FOR TESTING PURPOSES

/// Creates example notifications, part 1
class ExampleNotification extends StatefulWidget {
  const ExampleNotification( {Key? key})
      : super(key: key);

  @override
  _ExampleNotificationState createState() => _ExampleNotificationState();
}

/// Creates example notifications, part 2
class _ExampleNotificationState extends State<ExampleNotification> {

  // Helper for reminder notifications
  late var notifyHelper;

  // Initialize the reminder and notifications
  @override
  void initState() {
    super.initState();
  }

  DateTime test = DateTime(2021,11,26,6,15);

  @override
  Widget build(BuildContext context) {
    notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[// Example Notifications
      Text("\nBenachrichtigungen",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
      ),
      TextButton(
          onPressed: () {
            notifyHelper.displayNotification(
                id: 0,
                title: "Einfache Benachrichtigung",
                body: "Hallo das hier ist eine einfache Benachrichtigung",
              payload: "test",
                context: context
            );
          },
          child: Text("Einfache Benachrichtigung")),
      TextButton(
          onPressed: () {
            notifyHelper.scheduledNotification(
              id: 1,
              title: "Geplante Benachrichtigung (5 sek)",
              body: "Hallo das hier ist eine geplante Benachrichtigung von 5 Sekunden",
              seconds: 5,
              minutes: 0,
              hours: 0,
              days: 0,
            );
          },
          child: Text("Geplante Benachrichtigung (5 sek)")),
      TextButton(
          onPressed: () {
            notifyHelper.scheduledNotification1(test);
          },
          child: Text("Geplante Benachrichtigung (16.11.2021 17.20 Uhr)")),
      TextButton(
          onPressed: () {
            //notifyHelper.cancelNotifications(1);
            //notifyHelper.cancelNotifications(2;
            notifyHelper.cancelAllNotifications();
          },
          child: Text("Benachrichtigungen löschen"))

    ],
    );
  }
}
*/