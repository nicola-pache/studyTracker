import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/page/single_goal.dart';
import 'package:untitled/widget/calendar_event.dart';

/// The widget for the startpage, part 1.
/// Creates the state of the startpage.
///
/// The startpage contains a notifier for changes made to the goals, and a
/// notifier for changes made to the events.

class Startpage extends StatefulWidget {
  const Startpage({Key? key}) : super(key: key);

  static final ValueNotifier<bool> reloadGoals = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> reloadEvents = ValueNotifier<bool>(false);

  @override
  _StartpageState createState() => _StartpageState();
}

/// The widget for the startpage, part 2. It handles the state of the startpage.
/// The startpage shows a list of upcoming goals and a list of events for the
/// current day.
class _StartpageState extends State<Startpage> {

  /// Builds the startpage.
  /// The appBar shows the name of the app, the body contains cards for the
  /// goals and the events.
  @override
  Widget build(BuildContext context) {

    // Calculates the height of the spaces above and below the titles:
    // the empty cards for goals/events each take a fourth of the screen height,
    // the top and bottom bars together are little bit less than another fourth,
    // so the spaces must make up about a fourth too;
    // distribute the height onto four spaces and subtract 40 pts for the
    // fontSize of the titles
    double _spaceHeight = MediaQuery.of(context).size.height / 4 / 4 - 40;

    // If the spaces are smaller than 5 pts (on very small screens), then
    // the height is set to 5 pts
    if (_spaceHeight < 5) {
      _spaceHeight = 5;
    }

    return Scaffold(
        appBar: AppBar(title: const Text("studyTracker")),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(height: _spaceHeight),
              _goalsOverview(),
              SizedBox(height: _spaceHeight * 3),
              _timetableOverview()
            ])));
  }

  /// Shows a list of the next 5 goals, if available
  Widget _goalsOverview() {
    return Column(children: <Widget>[

        // Title
        const Text("Deine nächsten Ziele",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),

        // Card with the goals, which reloads if there is a change
        ValueListenableBuilder(
            valueListenable: Startpage.reloadGoals,
            builder: (context, value, _) {
              Widget _goals;
              List<Goal> _goalsList = Hive.box<Goal>('goals')
                  .values
                  .where((goal) =>
                      goal.deadline != null &&
                      DateTime.now().toUtc().isBefore(goal.deadline!) &&
                      !goal.isCompleted &&
                      !goal.isArchived)
                  .toList();
              if (_goalsList.isNotEmpty) {
                _goalsList.sort((a, b) => a.deadline!.compareTo(b.deadline!));
                List<Goal> _nextGoals = _goalsList.take(5).toList();
                _goals = Card(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _nextGoals.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              minLeadingWidth: 0,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              leading: Container(
                                  width: 12, color: _nextGoals[index].color),
                              title: Text(_nextGoals[index].name,
                                  style: const TextStyle(fontSize: 18),
                                  maxLines: 2),
                              subtitle: Text(
                                  _formatDeadline(_nextGoals[index].deadline!)),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SingleGoal(goal: _nextGoals[index]);
                                }));
                              });
                        }));
              } else {
                _goals = Card(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: double.maxFinite,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Du hast keine anstehenden Ziele.",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6))))));
              }
              return _goals;
            })
        ]);
  }

  /// Shows a list of the timetable events of the current day, if available
  Widget _timetableOverview() {
    return Column(
        children: <Widget>[

          // Title
          const Text("Deine heutigen Veranstaltungen",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),

          // Card with events, which reloads if there are changes
          ValueListenableBuilder(
            valueListenable: Startpage.reloadEvents,
            builder: (context, value, _) {
              Widget _events;
              List? _eventsList = Hive.box('timetableEvents')
                  .get(Hive.box('settings')
                  .get('currentlySelectedSemester'))
                  ?.values
                  .where((event) =>
                      event[4].weekday == DateTime.now().toUtc().weekday)
                  .toList();
              if (_eventsList != null && _eventsList.isNotEmpty) {
                //_eventsList.sort((a, b) => a[4].compareTo(b[4]);
                _events = Card(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _eventsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              minLeadingWidth: 0,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              leading: Container(
                                  width: 12, color: _eventsList[index][2]),
                              title: Text(_eventsList[index][0],
                                  style: const TextStyle(fontSize: 18),
                                  maxLines: 2),
                              subtitle: Text(CalendarEvent.formatEventTimes(
                                  _eventsList[index][4], _eventsList[index][5]))
                          );
                        }));
              } else {
                _events = Card(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: double.maxFinite,
                        child: Align(
                            alignment: Alignment.center,
                            child: Text("Du hast heute keine Veranstaltungen.",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6))))));
              }
              return _events;
            })
    ]);
  }

  /// Formats the deadline of a goal
  String _formatDeadline(DateTime deadline) {
    DateFormat _formatter = DateFormat(
        deadline.hour == 0 && deadline.minute == 0
            ? 'dd.MM.yyyy'
            : 'dd.MM.yyyy - HH:mm');
    return _formatter.format(deadline);
  }
}
