import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/timetable.dart';
import 'package:untitled/widget/timetable_event_dialog.dart';

import 'calendar.dart';

/// SingleTimetableEvent as a stateful widget, part 1.
/// Creates the state of the SingleTimetableEvent.
///
/// The SingleTimetableEvent needs the [startTime] of the event to identify the
/// event in the database.
/// It also requires the [parentContext] from the page navigation, so the
/// context is independent from any possible dialogs within this widget.
class SingleTimetableEvent extends StatefulWidget {
  const SingleTimetableEvent({required this.startTime, required this.parentContext,
    Key? key})
      : super(key: key);

  /// The start time of the timetable event.
  final DateTime startTime;

  /// The context from the page navigation.
  final BuildContext parentContext;

  @override
  _SingleTimetableEventState createState() => _SingleTimetableEventState();
}

/// Handles the state of the widget SingleTimeTableEvent.
/// This widget shows a page with the data of a selected timetable event.
class _SingleTimetableEventState extends State<SingleTimetableEvent> {

  /// List with all the data of the timetable event.
  late List _eventData;

  /// Initializes the widget by filling the [_eventData] list with the data
  /// from the database.
  @override
  void initState() {
    super.initState();
    _eventData = Hive.box('timetableEvents')
        .get(Hive.box('settings')
        .get('currentlySelectedSemester'))
        [widget.startTime.toString()];
  }

  /// Builds the widget.
  /// The appBar shows the name of the timetable event, a bar with its color,
  /// a button to change the data, and a button to delete the event.
  /// The body shows the data of the timetable event.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Text(_eventData[0]),
            Expanded(
                child: Divider(
                    thickness: 10.0,
                    indent: 10.0,
                    color: _eventData[2])),
              IconButton(
                icon: const Icon(Icons.create),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        bool _eventWasInCalendar = _eventData[6];
                        return TimetableDialog(
                            parentContext: widget.parentContext,
                            eventData: _eventData,
                            onSave: (FlutterWeekViewEvent _changedEvent,
                                bool showInCalendar) {
                              if (_eventWasInCalendar != showInCalendar) {
                                if (showInCalendar) {
                                  Calendar.updateCyclicCalenderEvents(
                                      event: _changedEvent);
                                } else {
                                  Calendar.updateCyclicCalenderEvents(
                                      oldStartTime: _eventData[4]);
                                }
                              } else if (showInCalendar) {
                                Calendar.updateCyclicCalenderEvents(
                                    oldStartTime: _eventData[4],
                                    event: _changedEvent);
                              }
                              _deleteEvent(_eventData[4]);
                              Timetable.timetableEvents.add(_changedEvent);
                              Timetable.saveTimetableEventInBox(
                                  _changedEvent, showInCalendar);
                              List _changedEventData = [_changedEvent.title,
                                _changedEvent.description,
                                _changedEvent.backgroundColor,
                                _changedEvent.textStyle!.color,
                                _changedEvent.start,
                                _changedEvent.end,
                                showInCalendar];
                              Timetable.timetableChanged.value =
                                  !Timetable.timetableChanged.value;
                              setState(() => _eventData = _changedEventData);
                            });
                      });
                },
              ),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _showDeleteWarning(_eventData);
                        });
                  }),
          ]),
          backwardsCompatibility: false, // use the specified foreground color
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Container(
          //padding: EdgeInsets.all(15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Card(child: _eventDescription()),
                ])));
  }

  /// Shows a dialog with a delete warning.
  /// The user can choose to delete the event or abort the deletion.
  AlertDialog _showDeleteWarning(List eventData) {
    return AlertDialog(
        title: const Text('Event löschen'),
        content: const Text(
            'Soll die Veranstaltung gelöscht werden?',
            style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton(
            child: const Text('NEIN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('JA', style: TextStyle(fontSize: 18)),
            onPressed: () {
              if (_eventData[6]) { // remove event if in calendar
                Calendar.updateCyclicCalenderEvents(oldStartTime: _eventData[4]);
              }
              _deleteEvent(_eventData[4]);
              Timetable.timetableChanged.value =
                  !Timetable.timetableChanged.value;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ]);
  }

  /// Formats the description of the event.
  Widget _eventDescription() {
    return Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(10.0),
        child: RichText(
            text: TextSpan(
                style: (TextStyle(
                    fontSize: 20.0,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                    fontWeight: FontWeight.normal)),
                children: <TextSpan>[
                  const TextSpan(
                      text: 'Name: ',
                      style: TextStyle(fontWeight: FontWeight.bold, height: 1.0)),
                  TextSpan(text: _eventData[0]),
                  const TextSpan(
                      text: '\nBeginn: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: DateFormat("HH:mm").format(_eventData[4]) + " Uhr"),
                  const TextSpan(
                      text: '\nEnde: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: DateFormat("HH:mm").format(_eventData[5]) + " Uhr"),
                  const TextSpan(
                      text: '\nRaum: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: _eventData[1] == ''
                      ? '-'
                      : _eventData[1].split('\n')[1])
                ])));
  }

  /// Deletes an event from a timetable.
  void _deleteEvent(DateTime startTime) {

    // Deletes the event from the current event list
    int length = Timetable.timetableEvents.length;
    bool _eventFound = false;
    int index = 0;
    while (index < length && !_eventFound) {
      _eventFound =
          Timetable.timetableEvents[index].start.compareTo(startTime) == 0;
      index++;
    }
    if (_eventFound) {
      Timetable.timetableEvents.removeAt(index - 1);
    }

    // Deletes the event from the HiveBox
    String _currentSemester = Hive.box('settings')
        .get('currentlySelectedSemester');
    Map<dynamic, dynamic> _currentEvents = Hive.box('timetableEvents')
        .get(_currentSemester);
    _currentEvents.remove(_eventData[4].toString());
    Hive.box('timetableEvents').put(_currentSemester, _currentEvents);
  }
}
