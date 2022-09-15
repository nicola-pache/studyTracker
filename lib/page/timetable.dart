import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:untitled/page/single_timetable_event.dart';
import 'package:untitled/page/startpage.dart';
import 'package:untitled/widget/timetable_event_dialog.dart';
import 'calendar.dart';

/// Timetable as a stateful widget, part 1.
/// Creates the state for the timetable widget.
/// Requires a [navigationContext] from the page navigation, so the widget will
/// be independent from contexts of dialogs within the widget itself.
class Timetable extends StatefulWidget {
  const Timetable(this.navigationContext, {Key? key}) : super(key: key);

  /// Fixed context, so the context still exists after dismissing dialogs
  final BuildContext navigationContext;

  /// Notifies all relevant widgets that the timetable has changed
  static final ValueNotifier<bool> timetableChanged =
      ValueNotifier<bool>(false);

  /// All the events of the currently selected timetable
  static List<FlutterWeekViewEvent> timetableEvents = [];

  /// Adds a new event as a list of information to the HiveBox.
  static void saveTimetableEventInBox(FlutterWeekViewEvent event,
      bool showInCalendar) {
    String _currentSemester = Hive.box('settings')
        .get('currentlySelectedSemester');
    List _newEvent = [event.title,
      event.description,
      event.backgroundColor,
      event.textStyle!.color,
      event.start,
      event.end,
      showInCalendar];
    Map<dynamic, dynamic> _currentEvents = Hive.box('timetableEvents')
        .get(_currentSemester);
    _currentEvents[event.start.toString()] = _newEvent;
    Hive.box('timetableEvents').put(_currentSemester, _currentEvents);
  }

  @override
  _TimetableState createState() => _TimetableState();
}

/// The state of the timetable widget.
/// The widget shows a timetable and its events.
class _TimetableState extends State<Timetable> {

  /// Fixed date for monday
  static DateTime monday = DateTime(1, 0, 4);

  /// Notifies all relevant widgets of changes made to the selected semester
  final ValueNotifier<bool> _semestersUpdated = ValueNotifier<bool>(false);

  /// Import information about the timetableEvents from the HiveBox
  void initializeEvents() {
      String _currentSemester =
          Hive.box('settings').get('currentlySelectedSemester');
      Hive.box('timetableEvents').get(_currentSemester).forEach((date, event) {
        Timetable.timetableEvents.add(
            FlutterWeekViewEvent(
                title: event[0],
                description: event[1],
                backgroundColor: event[2],
                textStyle: TextStyle(color: event[3]),
                start: event[4],
                end: event[5],
                onTap: () {
                  Navigator.push(widget.navigationContext,
                      MaterialPageRoute(builder: (context) {
                        return SingleTimetableEvent(
                            startTime: event[4],
                            parentContext: widget.navigationContext);
                      }));
                }
            ));
      });
  }

  /// Lets the user add a new semester.
  void _addNewSemester() {

    // Key to identify the state of the form and validate the inputs
    final GlobalKey<FormState> _addSemesterKey = GlobalKey<FormState>();

    // Shows a dialog with a textfield, where the user can enter the name of
    // the new semester
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Neuen Stundenplan erstellen"),
          content: Form(
              key: _addSemesterKey,
              child:TextFormField(
                style: const TextStyle(fontSize: 18),
                validator: (String? value) {
                  String? errorMsg;
                  if (value == null || value.isEmpty) {
                    errorMsg = 'Bitte benenne den neuen Stundenplan.';
                  }
                  return errorMsg;
                },
                onSaved: (String? value) {
                  Hive.box('timetableEvents').put(value, HashMap<String, List>());

                  // First timetable created will be the currently selected one
                  if (Hive.box('settings').get('currentlySelectedSemester') == '') {
                    Hive.box('settings').put('currentlySelectedSemester', value);
                    setState(() {});
                  }
                },
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
                _addSemesterKey.currentState!.reset();
              }),
              TextButton(
              child: const Text('ERSTELLEN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_addSemesterKey.currentState!.validate()) {
                  _addSemesterKey.currentState!.save();
                  Navigator.of(context).pop();
                  _addSemesterKey.currentState!.reset();
                  _semestersUpdated.value = !_semestersUpdated.value;
                }
              })
        ]);
      }
    );
  }

  /// Shows a dialog which warns the user of deleting a semester.
  void  _showDeleteWarning(String semester) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Stundenplan löschen'),
              content: const Text(
                 'Achtung! Der ausgewählte Stundenplan wird unwiderruflich '
                     'gelöscht!',
                  style: TextStyle(fontSize: 18)),
              actions: <Widget>[
                TextButton(
                  child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('LÖSCHEN', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                      Hive.box('timetableEvents').delete(semester);
                      _semestersUpdated.value = !_semestersUpdated.value;
                      Navigator.of(context).pop();
                  },
                )
              ]);
        }
    );
  }

  /// The user can select a semester to be displayed on the timetable.
  void _selectSemester() {

    // Shows a dialog with the list of all available semesters
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                const Flexible(child: Text("Anderen Stundenplan auswählen")),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewSemester)
                ]),
            content: SizedBox(
                width: MediaQuery.of(context).size.height / 3,
                child: ValueListenableBuilder(
                  valueListenable: _semestersUpdated,
                  builder: (BuildContext context, bool value, _) {

                    // List of all available semesters except the current one
                    List _semesters = Hive.box('timetableEvents').keys.toList();
                    _semesters.remove(Hive.box('settings')
                        .get('currentlySelectedSemester'));

                    return Scrollbar(
                      interactive: true,
                      child: _semesters.isNotEmpty
                          ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _semesters.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                title: Text(_semesters[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteWarning(_semesters[index]);
                                  }
                                ),
                                onTap: () {
                                  Hive.box('settings')
                                      .put('currentlySelectedSemester',
                                      _semesters[index]);
                                  _semestersUpdated.value =
                                    !_semestersUpdated.value;
                                  Timetable.timetableEvents.clear();
                                  initializeEvents();
                                  Timetable.timetableChanged.value =
                                      !Timetable.timetableChanged.value;
                                  Calendar.cyclicEvents.clear();
                                  Hive.box('timetableEvents').get(Hive.box('settings')
                                      .get('currentlySelectedSemester'))?.values
                                      .forEach((event) {
                                    // if event is supposed to be shown in the calendar
                                    if (event[6]) {
                                      FlutterWeekViewEvent _newEvent =
                                        FlutterWeekViewEvent(
                                          title: event[0],
                                          description: event[1],
                                          backgroundColor: event[2],
                                          textStyle: TextStyle(color: event[3]),
                                          start: event[4],
                                          end: event[5]);
                                      Calendar.addTimetableEventToCalendar(_newEvent);
                                    }
                                  });
                                  Calendar.resetCalendarState.value =
                                    !Calendar.resetCalendarState.value;
                                  Navigator.of(context).pop();
                                }
                            );
                          })
                          : Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child: Text("Keine weiteren Stundenpläne vorhanden.",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4)))
                      ),
                    );
                  })
        ));
      }
    );
  }

  /// Initializes the timetable.
  /// If the timetable is opened for the first time, or no timetable has been
  /// created so far, the dialog for adding a new semester will be shown.
  /// If at least one timetable exists, the currently selected timetable will
  /// be loaded.
  @override
  void initState() {
    super.initState();
    if (Hive.box('settings').get('currentlySelectedSemester') == '') {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        _addNewSemester();
      });
    } else if (Timetable.timetableEvents.isEmpty) {
      initializeEvents();
    }
  }

  /// Builds the timetable.
  /// The appBar shows a button, which opens a lists of semesters, the name
  /// of the currently shown semester, and a button to add a new event.
  /// The body shows the currently selected timetable. The user can tap on
  /// an event to open a page with detailed information about the event.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.folder, size: 35),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _selectSemester()
          ),
          title: Center(
            child: ValueListenableBuilder(
              valueListenable: _semestersUpdated,
              builder: (BuildContext context, bool value, _) {
                return Text(Hive.box('settings').get('currentlySelectedSemester'));
              }
            )
          ),
          actions: <Widget>[
            Container(
                padding: const EdgeInsets.only(right: 20.0),
                // IconButton to add a goal
                child: IconButton(
                    icon: const Icon(Icons.add_circle, size: 40.0),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: Hive.box('timetableEvents').isEmpty
                      ? null
                      : () {
                        showDialog(
                            context: widget.navigationContext,
                            barrierDismissible: false,
                          builder: (BuildContext context) {
                            return TimetableDialog(
                                parentContext: widget.navigationContext,
                                onSave: (FlutterWeekViewEvent event,
                                    bool showInCalendar) {
                                  if (showInCalendar) {
                                    Calendar.updateCyclicCalenderEvents(
                                        event: event);
                                  }
                                  Timetable.timetableEvents.add(event);
                                  Timetable.saveTimetableEventInBox(
                                      event, showInCalendar);
                                  Timetable.timetableChanged.value =
                                      !Timetable.timetableChanged.value;
                                  Startpage.reloadGoals.value =
                                      !Startpage.reloadGoals.value;
                                });
                          });
                        }
                    ))
          ],
        ),
        body: ValueListenableBuilder(
            valueListenable: Timetable.timetableChanged,
            builder: (BuildContext context, bool value, _) {
              return WeekView(
                  minimumTime: _convertFromTimeOfDay(
                      Hive.box('settings').get('timetableStart'))
                      .subtract(const HourMinute(minute: 1)
                  ),
                  maximumTime: _convertFromTimeOfDay(
                      Hive.box('settings').get('timetableEnd')),
                  dayViewStyleBuilder: (date) => DayViewStyle(
                      hourRowHeight: 100.0,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundRulesColor:
                          Theme.of(context).colorScheme.onSurface),
                  dayBarStyleBuilder: (date) => DayBarStyle(
                      dateFormatter: (y, m, d) =>
                          DateFormat.E('de_DE').format(date),
                      color: Theme.of(context).colorScheme.background),
                  hoursColumnStyle: HoursColumnStyle(
                    timeFormatter: (time) => "\n"
                        + time.hour.toString().padLeft(2, '0')
                        + ":"
                        + time.minute.toString().padLeft(2, '0'),
                    width: (MediaQuery.of(context).size.width) / 6 - 5,
                    textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  style: WeekViewStyle(
                      dayViewWidth: (MediaQuery.of(context).size.width) / 6,
                      dayViewSeparatorWidth: 1,
                      dayViewSeparatorColor:
                          Theme.of(context).colorScheme.onSurface),
                  initialTime: const HourMinute(hour: 7).atDate(DateTime.now()),
                  dates: <DateTime>[
                    monday,
                    monday.add(const Duration(days: 1)),
                    monday.add(const Duration(days: 2)),
                    monday.add(const Duration(days: 3)),
                    monday.add(const Duration(days: 4))
                  ],
                  events: Timetable.timetableEvents);
            }));
  }

  /// Converts a TimeOfDay type to the HourMinute type, which is required for
  /// the timetable events
  HourMinute _convertFromTimeOfDay(TimeOfDay timeOfDay) {
    return HourMinute(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }
}
