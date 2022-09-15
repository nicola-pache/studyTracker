import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/widget/calendar_event.dart';
import 'dart:core';
import 'package:untitled/model/goals_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


/// Calender as a stateful widget, part 1
/// Creates the state for the calendar widget.
/// Requires a [navigationContext] from the page navigation, so the widget will
/// be independent from contexts of dialogs within the widget itself.
class Calendar extends StatefulWidget {
  const Calendar(this.navigationContext, {Key? key}) : super(key: key);

  /// Fixed context, so the context still exists after dismissing dialogs.
  final BuildContext navigationContext;

  @override
  _CalendarState createState() => _CalendarState();

  /// Notifies all relevant widgets that the calendar needs to be reset.
  static final ValueNotifier<bool> resetCalendarState = ValueNotifier(false);

  /// Contains all events displayed in the calendar.
  static LinkedHashMap events = LinkedHashMap<DateTime, HiveList<Goal>>(
    equals: isSameDay,
  );

  /// Map for cyclic events with the weekday as int as key and a list of the
  /// timetable events as value.
  static LinkedHashMap cyclicEvents = LinkedHashMap<int,
      List<FlutterWeekViewEvent>>();

  /// Updates the calendarMap after a goal is added.
  static void updateCalendarEvents(
      {required Goal goal, DateTime? oldDeadline}) {
    // If the goal had a deadline before, the old goal needs to be removed
    // from the calendar map.
    if (oldDeadline != null) {
      removeGoalFromCalendar(oldDeadline, goal);
    }

    // Add the goal to the calendar map
    addGoalToCalendar(goal);

    Calendar.resetCalendarState.value = !Calendar.resetCalendarState.value;
  }

  /// Adds a goal to the calendar.
  static void addGoalToCalendar(Goal goal) {
    if (goal.deadline != null) {

      DateTime time = goal.deadline ?? DateTime.now();
      DateTime deadlineShort = DateTime.utc(time.year, time.month, time.day);
      if (events.containsKey(deadlineShort)) {
        events[deadlineShort].add(goal);
      } else {
        HiveList<Goal> eventsList = HiveList(Hive.box<Goal>('goals'));
        eventsList.add(goal);
        events[deadlineShort] = eventsList;
      }
    }
  }

  /// Removes a goal from the calendar.
  static void removeGoalFromCalendar(DateTime oldDeadline, Goal goal) {
    DateTime time = oldDeadline;
    DateTime deadlineShort = DateTime.utc(time.year, time.month, time.day);
    if (events.containsKey(deadlineShort)) {
      events[deadlineShort].remove(goal);
    }
  }

  /// Adds a timetable event to the calendar, or removes an old one. The calendar
  /// will then be updated.
  static void updateCyclicCalenderEvents({DateTime? oldStartTime,
      FlutterWeekViewEvent? event}) {

    // Removes the old event which is identified by its old start time
    if (oldStartTime != null) {
      removeTimetableEventFromCalendar(oldStartTime);
    }

    // Adds the timetable event to the calendar map
    if (event != null) {
      addTimetableEventToCalendar(event);
    }

    Calendar.resetCalendarState.value = !Calendar.resetCalendarState.value;
  }

  /// Adds a timetable event to the calendar.
  static void addTimetableEventToCalendar(FlutterWeekViewEvent event) {
    int weekday = event.start.weekday;
    if (cyclicEvents.containsKey(weekday)) {
      cyclicEvents[weekday].add(event);
    } else {
      cyclicEvents[weekday] = [event];
    }
  }

  /// Removes a timetable event from the calendar; the event is identified by
  /// its unique startTime.
  static void removeTimetableEventFromCalendar(DateTime startTime) {
    if (cyclicEvents.containsKey(startTime.weekday)) {
      cyclicEvents[startTime.weekday]
          .removeWhere((event) => event.start == startTime);
    }
  }
}

/// Calender as a stateful widget, part 2
/// The widget displays a calendar with markers representing events.
class _CalendarState extends State<Calendar> {

  /// Notifies all relevant widgets when the selected events have changed.
  late final ValueNotifier<List> _selectedEvents;

  /// Focused current day in the calendar.
  late DateTime _focusedDay = DateTime.now().toUtc();

  /// Selected day in the calendar.
  late DateTime _selectedDay = DateTime.now().toUtc();

  /// The format of the calendar.
  /// Can be changed to month or week format.
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// Initializes the calendar.
  /// The displayed month when opening the calendar is the current month.
  @override
  void initState() {
    super.initState();

    // Gets current date and time.
    DateTime _now = DateTime.now();

    // Saves only the current date, the time is removed.
    DateTime _date = DateTime.utc(_now.year, _now.month, _now.day);

    _focusedDay = _date;
    _selectedDay = _date;

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  /// Disposes of the selected events.
  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  /// Gives a list of events for the selected day.
  List _getEventsForDay(DateTime? day) {

    // Collects the events for the selected day from the normal and the cyclic
    // events.
    List eventsForDay = [];
    if (day != null) {
      if (Calendar.cyclicEvents.containsKey(day.weekday)) {
        eventsForDay.addAll(Calendar.cyclicEvents[day.weekday]);
      }
      if (Calendar.events.containsKey(day)) {
        eventsForDay.addAll(Calendar.events[day]);
      }
    }

    // Gets the deadline or the start time of the event, depending on its type;
    // for better comparison, it retrieves only the time in minutes of the
    // deadline/start time, because the start time does not have a date.
    eventsForDay.sort((a, b) {
      DateTime _timeA = a is Goal ? a.deadline : a.start;
      DateTime _timeB = b is Goal ? b.deadline : b.start;
      int _timeAInMinutes = _timeA.hour * 60 + _timeA.minute;
      int _timeBInMinutes = _timeB.hour * 60 + _timeB.minute;
      return _timeAInMinutes.compareTo(_timeBInMinutes);
    });

    return eventsForDay;
  }

  /// Updates the selected day and calls _getEventsForDay.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if(!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;

        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  /// Shows a maximum of 5 markers representing events per day and
  /// adopts the event's color.
  Widget _showMarkers(List events) {
    final _markers = <Widget>[];
    for (var event in events.take(5)) {
      _markers.add(Container(
          margin: EdgeInsets.symmetric(horizontal: 1.0),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: event is Goal ? event.color : event.backgroundColor,
              shape: BoxShape.circle
          )
      ));
    }
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _markers);
  }

  /// Displays date positioned between calendar and the list of events
  /// if the selected day contains events.
  Widget _displayDate() {
    Widget _date;
    if (_getEventsForDay(_selectedDay).isEmpty) {
      _date = SizedBox(height: 8.0);
    } else {
      String _formattedDay = DateFormat.yMMMMd('de_DE').format(_selectedDay);
      _date = Container(
          padding: EdgeInsets.all(20.0),
          child: Row(
              children: <Widget> [
                Expanded(
                    child: Divider(thickness: 2.0, endIndent: 10.0)
                ),
                Text(_formattedDay,
                    style: TextStyle(
                      fontSize: 20,
                    )
                ),
                Expanded(
                    child: Divider(thickness: 2.0, indent: 10.0)
                ),
              ]
          )
      );
    }
    return _date;
  }

  /// Builds the calendar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder(
            valueListenable: Calendar.resetCalendarState,
            builder: (context, value, _) {
              _selectedEvents.value = _getEventsForDay(_selectedDay);
              return /**SingleChildScrollView(
                  child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: **/
                  Column(children: [
                TableCalendar(
                  firstDay: DateTime(2010),
                  lastDay: DateTime(2050),
                  focusedDay: _focusedDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: 'de_DE',
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      )),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Monat',
                    CalendarFormat.week: 'Woche'
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                  calendarBuilders:
                      CalendarBuilders(markerBuilder: (context, day, events) {
                    Widget? marker;
                    if (events.isNotEmpty) {
                      marker = _showMarkers(events);
                    }
                    return marker;
                  }),
                ),
                _displayDate(),
                // Builds list of events for the selected day
                Expanded(
                    child: ValueListenableBuilder<List>(
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) {
                          return ListView.builder(
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                return CalendarEvent(
                                    event: value[index],
                                    navigationContext:
                                        widget.navigationContext);
                              });
                        }))
              ]) /**))**/;
            }));
  }
}