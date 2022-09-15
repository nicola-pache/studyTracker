import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/page/single_goal.dart';
import 'package:untitled/page/single_timetable_event.dart';


/// Shows an event in the calendar.
class CalendarEvent extends StatelessWidget {
  const CalendarEvent({required this.event, required this.navigationContext,
    Key? key}) : super(key: key);

  /// The event.
  final dynamic event;

  /// The navigationContext of the event. It makes sure the context is always
  /// available.
  final BuildContext navigationContext;

  /// Formats the deadline of a goal.
  String _formatGoalDeadline(DateTime? deadline) {
      String deadlineTextformat = (deadline == null)
          ? ""
          : (deadline.hour == 0 && deadline.minute == 0)
          ? DateFormat('dd.MM.yy').format(deadline)
          : DateFormat('dd.MM.yy - HH:mm').format(deadline);

      return deadlineTextformat;
  }

  /// Formats the start and end times of a timetable event.
  static String formatEventTimes(DateTime start, DateTime end) {
    String _startHours = DateFormat('HH:mm').format(start);
    String _endHours = DateFormat('HH:mm').format(end);
    return _startHours + ' - ' + _endHours;
  }

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    // Get all the information based on the type of the event
    Color _color;
    String _title;
    String _subtitle;
    Function() _onTap;
    if (event is Goal) {
      _color = event.color;
      _title = event.name;
      _subtitle = _formatGoalDeadline(event.deadline);
      _onTap = () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return SingleGoal(goal: event);
            }));
      };
    } else {
      _color = event.backgroundColor;
      _title = event.title;
      _subtitle = formatEventTimes(event.start, event.end);
      _onTap = () {
        Navigator.push(navigationContext,
            MaterialPageRoute(builder: (context) {
              return SingleTimetableEvent(
                  parentContext: navigationContext,
                  startTime: event.start);
            }));
      };
    }

    // Build the card to display the event below the calendar
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                width: 12.0,
                color: _color,
              ))),
      child: ListTile(
        onTap: _onTap,
        title: Text(_title),
        subtitle: Text(_subtitle),
      ),
    );
  }
}
