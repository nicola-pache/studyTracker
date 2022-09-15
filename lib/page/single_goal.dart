import 'package:awesome_circular_chart/awesome_circular_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/modules.dart';
import 'package:untitled/page/startpage.dart';
import 'package:untitled/widget/goal_dialog.dart';
import '../notification_services.dart';
import 'goals.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:hive/hive.dart';
import 'calendar.dart';
import 'package:untitled/model/modules_model.dart';

/// SingleGoal as a stateful widget, part 1.
/// Creates the state of the SingleGoal.
///
/// The SingleGoal requires a [goal] to display this content.
class SingleGoal extends StatefulWidget {
  const SingleGoal({required this.goal, Key? key}) : super(key: key);
  final Goal goal;

  @override
  _SingleGoalState createState() => _SingleGoalState();
}

/// Handles the state of the SingleGoal.
/// This widget shows a page with data from a goal.
class _SingleGoalState extends State<SingleGoal> {
  /// Information about the active timer:
  /// if the timer of the current goal is running,
  /// the current goal cannot be deleted.
  final List? _activeTimer = Hive.box('timer').get('activeTimer');

  /// Builds the SingleGoal view.
  ///
  /// The appbar contains the goals name.
  /// The body shows the data from the goal and 3 buttons for
  /// editing, deleting or completing the goal.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.goal.name),
          backwardsCompatibility: false,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Container(
            padding: EdgeInsets.all(15.0),
            child: SingleChildScrollView(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Row(children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withOpacity(0.8),
                                        width: 1),
                                    color: widget.goal.color,
                                  ),
                                ),
                              ),
                              // IconButton to edit this goal.
                              IconButton(
                                icon: const Icon(
                                  Icons.create,
                                  semanticLabel: "Ziel bearbeiten",
                                ),
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        String _oldModule = widget.goal.module;
                                        DateTime? _oldDeadline =
                                            (widget.goal.deadline);
                                        return GoalDialog(
                                            context: context,
                                            title: "Ziel bearbeiten",
                                            isTemplate: false,
                                            goal: widget.goal,
                                            onSave: (Goal goal) {
                                              goal.save();
                                              setState(() {});
                                              GoalsList.updateGoals();
                                              if (goal.module != _oldModule) {
                                                Module newModule =
                                                    Hive.box<Module>('modules')
                                                        .get(goal.module)!;
                                                newModule.goals.add(goal);
                                                newModule.save();
                                                Module oldModule =
                                                    Hive.box<Module>('modules')
                                                        .get(_oldModule)!;
                                                oldModule.goals.remove(goal);
                                                oldModule.save();
                                                ModulesList
                                                        .resetModuleList.value =
                                                    !ModulesList
                                                        .resetModuleList.value;
                                              }
                                              if (goal.deadline !=
                                                  _oldDeadline) {
                                                Calendar.updateCalendarEvents(
                                                    oldDeadline: _oldDeadline,
                                                    goal: goal);
                                              }
                                              Startpage.reloadGoals.value =
                                                  !Startpage.reloadGoals.value;
                                            });
                                      });
                                },
                              ),
                              // IconButton to delete this goal.
                              IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    semanticLabel: "Ziel löschen",
                                  ),
                                  alignment: Alignment.centerRight,
                                  onPressed: _activeTimer != null &&
                                          _activeTimer![0] == 0 &&
                                          _activeTimer![1] ==
                                              widget.goal.creationDate
                                      ? null
                                      : () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _showDeleteWarning(
                                                    widget.goal.creationDate);
                                              });
                                        }),
                              // IconButton to (un)mark this goal as completed.
                              StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return IconButton(
                                    icon: widget.goal.isCompleted
                                        ? Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: widget.goal.color),
                                            child: Icon(
                                              Icons.check,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              semanticLabel: "Ziel erledigt",
                                            ))
                                        : const Icon(
                                            Icons.check,
                                            semanticLabel:
                                                "Ziel doch nicht erledigt",
                                          ),
                                    alignment: Alignment.centerRight,
                                    onPressed: () {
                                      setState(() => _markGoal(widget.goal));
                                    });
                              })
                            ]),
                          ),
                          _goalDescription(context, widget.goal),
                          compareTimeLearned()
                        ])))));
  }

  /// Formats the goal description.
  Widget _goalDescription(BuildContext context, Goal goal) {
    return Column(children: <Widget>[
      RichText(
          text: TextSpan(
              style: (TextStyle(
                  fontSize: 20.0,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                  fontWeight: FontWeight.normal)),
              children: <TextSpan>[
            const TextSpan(
                text: 'Fälligkeitsdatum: ',
                style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
            TextSpan(
              text: (_showDeadline(goal.deadline)),
              style: TextStyle(
                color: (goal.deadline != null &&
                        goal.isCompleted == false &&
                        DateTime.now().isAfter(goal.deadline ?? DateTime.now()))
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const TextSpan(
                text: '\nZeitaufwand: ',
                style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
            TextSpan(text: _showEstimatedTime(goal.estimatedTime)),
            const TextSpan(
                text: '\nErinnerung: ',
                style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
            TextSpan(text: goal.reminder),
            const TextSpan(
                text: '\nModul: ',
                style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
            TextSpan(
                text: goal.module != '0'
                    ? Hive.box<Module>('modules').get(goal.module)!.name
                    : '-'),
            const TextSpan(
                text: '\nAnmerkungen: ',
                style: TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
            TextSpan(text: goal.notes ?? '-'),
          ]))
    ]);
  }

  /// Shows the deadline in the right format for the goalDescription.
  String _showDeadline(DateTime? deadline) {
    String deadlineTextformat = (deadline == null)
        ? ""
        : (deadline.hour == 0 && deadline.minute == 0)
            ? DateFormat('dd.MM.yy').format(deadline)
            : DateFormat('dd.MM.yy - HH:mm').format(deadline);

    return deadlineTextformat;
  }

  /// Shows the estimatedTime in the right format for the goalDescription.
  String _showEstimatedTime(Duration? duration) {
    String durationText = (duration == null || duration.inMinutes == 0)
        ? "Keine Angabe"
        : "${duration.inHours.toString().padLeft(2, '0')} Std. ${duration.inMinutes.remainder(60).toString().padLeft(2, '0')} Min.";

    return durationText;
  }

  /// Shows a dialog with a delete warning.
  /// The user can choose to delete the goal or abort the deletion.
  AlertDialog _showDeleteWarning(String creationDate) {
    return AlertDialog(
        title: const Text('Ziel löschen'),
        content: const Text(
            'Achtung: beim Löschen des Ziels wird auch die '
            'angerechnete Zeit gelöscht!',
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
              setState(() {
                Calendar.resetCalendarState.value =
                    !Calendar.resetCalendarState.value;
                ModulesList.resetModuleList.value =
                    !ModulesList.resetModuleList.value;
                Startpage.reloadGoals.value = !Startpage.reloadGoals.value;
                Hive.box<Goal>('goals').delete(creationDate);
                GoalsList.changeToGoalsList.value =
                    !GoalsList.changeToGoalsList.value;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            },
          )
        ]);
  }

  /// Turn String reminder into a duration.
  Duration _getDuration(String reminder) {
    String reminderTrimmed = reminder.replaceAll(" vorher", "");
    int reminderNumber =
        int.parse(reminderTrimmed.replaceAll(RegExp('[^0-9]'), ''));

    Duration reminderDuration = (reminderTrimmed.endsWith("Stunde") |
            reminderTrimmed.endsWith("Stunden"))
        ? new Duration(hours: reminderNumber)
        : (reminderTrimmed.endsWith("Tag") | reminderTrimmed.endsWith("Tage"))
            ? new Duration(days: reminderNumber)
            : (reminderTrimmed.endsWith("Woche") |
                    reminderTrimmed.endsWith("Wochen"))
                ? new Duration(days: 7 * reminderNumber)
                : new Duration(minutes: reminderNumber);

    return reminderDuration;
  }

  /// Get the id for the notification from a goals creationDate.
  int _getIdFromCreationDate(String creationDate) {
    String idString =
        (creationDate.replaceAll(RegExp('[^0-9]'), '')).substring(4, 14);
    int idInt = int.parse(idString);

    return idInt;
  }

  /// (Un)marks the goal as completed.
  void _markGoal(Goal goal) {
    goal.isCompleted = !goal.isCompleted;
    goal.save();
    GoalsList.updateGoals();
    ModulesList.resetModuleList.value = !ModulesList.resetModuleList.value;
    if (goal.isCompleted) {
      if (goal.deadline != null) {
        Calendar.removeGoalFromCalendar(goal.deadline!, goal);
      }
      if (goal.reminder != "Keine Erinnerung" && goal.reminder != null) {
        if (goal.reminder != "Keine Erinnerung" && goal.reminder != null) {
          // Helper for reminder notifications.
          var notifyHelper = NotifyHelper(context: context);
          notifyHelper.initializeNotification();
          notifyHelper.requestIOSPermissions();
          notifyHelper
              .deleteNotification(_getIdFromCreationDate(goal.creationDate));
        }
      }
    } else {
      if (goal.deadline != null) {
        Calendar.addGoalToCalendar(goal);
        if (goal.reminder != null) {
          bool isBeforeDeadline = goal.deadline!
              .isAfter(DateTime.now().add(_getDuration(goal.reminder!)));
          if (isBeforeDeadline) {
            var notifyHelper = NotifyHelper(context: context);
            notifyHelper.initializeNotification();
            notifyHelper.requestIOSPermissions();
            notifyHelper.scheduledNotification(
                _getIdFromCreationDate(goal.creationDate),
                goal.deadline!,
                _getDuration(goal.reminder!),
                "Erinnerung für: " + goal.name,
                "Hallo! Vergiss nicht \"" +
                    goal.name +
                    "\" in " +
                    (goal.reminder.toString()).replaceAll(" vorher", "") +
                    ".",
                "payload",
                context);
          }
        }
      }
    }
  }

  /// Returns a circular chart comparing [estimatedTime] and [timeLearned] if
  /// there is an [estimatedTime].
  /// If the [timeLearned] is greater than [estimatedTime] an additional circle
  /// will be added. There can be a maximum of three circles.
  Widget compareTimeLearned() {
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        GlobalKey<AnimatedCircularChartState>();
    Widget chart;
    if (widget.goal.estimatedTime == null ||
        widget.goal.estimatedTime == Duration.zero) {
      chart = SizedBox(height: 2.0);
    } else {
      List<CircularStackEntry> data = [];
      double timeLearned = widget.goal.timeLearned.inMinutes.toDouble();
      double estimatedTime = widget.goal.estimatedTime!.inMinutes.toDouble();
      double fillingCircle = timeLearned - (2 * estimatedTime);
      if (widget.goal.timeLearned.inMinutes >=
          (2 * widget.goal.estimatedTime!.inMinutes)) {
        data = <CircularStackEntry>[
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(100.0, widget.goal.color),
          ]),
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(100.0, widget.goal.color),
          ]),
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(
                ((fillingCircle * 100) / estimatedTime), widget.goal.color),
            CircularSegmentEntry(
                ((estimatedTime - fillingCircle) * 100) / estimatedTime,
                Colors.grey[300])
          ]),
        ];
      } else if (widget.goal.timeLearned.inMinutes >=
          widget.goal.estimatedTime!.inMinutes) {
        data = <CircularStackEntry>[
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(100.0, widget.goal.color),
          ]),
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(
                ((fillingCircle * 100) / estimatedTime), Colors.grey[300]),
            CircularSegmentEntry(
                ((estimatedTime - fillingCircle) * 100) / estimatedTime,
                widget.goal.color)
          ]),
        ];
      } else {
        data = <CircularStackEntry>[
          CircularStackEntry(<CircularSegmentEntry>[
            CircularSegmentEntry(
                (timeLearned / estimatedTime) * 100.0, widget.goal.color),
            CircularSegmentEntry(
                ((estimatedTime - timeLearned) / estimatedTime) * 100.0,
                Colors.grey[300])
          ])
        ];
      }
      chart = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
                text: TextSpan(
                    style: (TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                        fontWeight: FontWeight.normal)),
                    children: <TextSpan>[
                  TextSpan(
                      text: 'Aufgenommene Zeit: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
                ])),
            AnimatedCircularChart(
              key: _chartKey,
              size: Size(MediaQuery.of(context).size.height / 3,
                  MediaQuery.of(context).size.height / 3),
              initialChartData: data,
              chartType: CircularChartType.Radial,
              percentageValues: true,
              holeLabel: widget.goal.timeLearned
                  .toString()
                  .split('.')
                  .first
                  .padLeft(8, "0"),
              labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0),
            )
          ]);
    }
    return chart;
  }
}
