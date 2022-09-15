import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/startpage.dart';
import 'package:untitled/widget/goal_dialog.dart';
import 'package:untitled/widget/settings_goals/template_manager.dart';
import 'package:untitled/widget/template_picker.dart';
import '../notification_services.dart';
import 'calendar.dart';
import 'modules.dart';
import 'single_goal.dart';
import 'package:untitled/widget/settings_goals/settings_button_goals.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:hive/hive.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:untitled/widget/timer_button.dart';
import '../page_navigation.dart';

/// GoalsList as a stateful widget, part 1.
/// Creates the state of the GoalsList.
///
/// The GoalsList contains a list of goals saved in the HiveBox [goals],
/// and a notifier [changeToGoalsList] for changes made to the goals.
class GoalsList extends StatefulWidget {
  GoalsList({Key? key}) : super(key: key);

  static HiveList<Goal> goals = HiveList(Hive.box<Goal>('goals'));

  static ValueNotifier<bool> changeToGoalsList = ValueNotifier<bool>(false);

  @override
  _GoalsListState createState() => _GoalsListState();

  /// Updates the goals.
  static void updateGoals() {
    _filterGoals();
    GoalsList.goals.sort(Goal.goalComparator());
    GoalsList.changeToGoalsList.value = !GoalsList.changeToGoalsList.value;
  }

  /// Filters the goals.
  static void _filterGoals() {
    String _currentlySelectedFilter = Hive.box('settings').get('goalsFilter');
    GoalsList.goals.clear();
    if (_currentlySelectedFilter == 'openGoals') {
      GoalsList.goals.addAll(Hive.box<Goal>('goals')
          .values
          .where((goal) => !goal.isCompleted && !goal.isArchived)
          .toList());
    } else if (_currentlySelectedFilter == 'completedGoals') {
      GoalsList.goals.addAll(Hive.box<Goal>('goals')
          .values
          .where((goal) => goal.isCompleted && !goal.isArchived)
          .toList());
    } else {
      GoalsList.goals.addAll(Hive.box<Goal>('goals')
          .values
          .where((goal) => !goal.isArchived)
          .toList());
    }
  }
}

/// Handles the state of the GoalsList.
/// This widget shows a page with a list of all currently visible goals.
class _GoalsListState extends State<GoalsList>
    with AutomaticKeepAliveClientMixin {
  /// the box with the goals for easier reference.
  Box<Goal> goalsBox = Hive.box<Goal>('goals');

  /// Initializes the goals and the template manager.
  @override
  void initState() {
    super.initState();

    // Adds, filters, and sorts the goals from the HiveBox.
    GoalsList.goals.addAll(goalsBox.values.toList());
    GoalsList._filterGoals();
    GoalsList.goals.sort(Goal.goalComparator());

    // Adds and sorts the templates from the HiveBox.
    TemplateManager.templates
      ..addAll(Hive.box<Goal>('goalsTemplates').values.toList())
      ..sort((a, b) => a.name.compareTo(b.name));

    SelectTemplate.templates
      ..addAll(Hive.box<Goal>('goalsTemplates').values.toList())
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Builds a list of GoalTiles.
  ///
  /// The appbar contains a button to access sorting, filters
  /// and the manager for templates and reminders.
  /// As well as a button to add a new goal.
  /// The body shows all the currently visible goals.
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: SettingsButtonGoals(),
          centerTitle: false,
          actions: <Widget>[
            Container(
                padding: EdgeInsets.only(right: 20.0),
                // IconButton to add a goal.
                child: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 40.0,
                      semanticLabel: "Ziel hinzufügen",
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return GoalDialog(
                                context: context,
                                title: "Ziel hinzufügen",
                                isTemplate: false,
                                onSave: (Goal goal) {
                                  GoalsList.changeToGoalsList.value =
                                      !GoalsList.changeToGoalsList.value;
                                  goalsBox.put(goal.creationDate, goal);
                                  GoalsList.goals.add(goal);
                                  GoalsList.goals.sort(Goal.goalComparator());
                                  Module module = Hive.box<Module>('modules')
                                      .get(goal.module)!;
                                  module.goals.add(goal);
                                  module.save();
                                  Calendar.updateCalendarEvents(goal: goal);
                                  Startpage.reloadGoals.value =
                                      !Startpage.reloadGoals.value;
                                  ModulesList.resetModuleList.value =
                                      !ModulesList.resetModuleList.value;
                                });
                          });
                    }))
          ],
        ),
        body: ValueListenableBuilder<bool>(
            valueListenable: GoalsList.changeToGoalsList,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: GoalsList.goals.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildGoalTile(index);
                },
              );
            }));
  }

  /// Builds the tile for a goal.
  ///
  /// A single tile consists of the goals color, the name and deadline,
  /// as well as the button for the timer.
  Widget _buildGoalTile(int index) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      Goal goal = GoalsList.goals[index];
      return Card(
          child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(5.0),
              // Adds a colored bar on the left side of a tile.
              decoration: BoxDecoration(
                  border:
                      Border(left: BorderSide(width: 12.0, color: goal.color))),
              child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  title: Text(goal.name,
                      style: const TextStyle(fontSize: 25), maxLines: 2),
                  subtitle: Text(
                    _showDeadline(goal.deadline),
                    semanticsLabel: (goal.deadline != null)
                        ? "Fälligkeitsdatum" + goal.deadline.toString()
                        : "",
                    style: TextStyle(
                      color: (goal.deadline != null &&
                              goal.isCompleted == false &&
                              DateTime.now()
                                  .isAfter(goal.deadline ?? DateTime.now()))
                          ? Colors.red
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                  trailing: goal.isCompleted
                      // Icon to mark a goal as completed.
                      ? Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: goal.color),
                          constraints:
                              BoxConstraints.tightForFinite(width: 105),
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.surface,
                            size: 34,
                            semanticLabel: "Ziel erledigt",
                          ))
                      // Button for the timer.
                      : ValueListenableBuilder<bool>(
                          builder: (context, value, _) {
                            return TimerButton(context, [0, goal.creationDate]);
                          },
                          valueListenable: Navigation.timerActivated),
                  onTap: () {
                    // Opens the SingleGoal view.
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SingleGoal(goal: goal);
                    }));
                  },
                  // Shortcut to mark a goal as completed.
                  onLongPress: () {
                    _onLongPressGoalTile(goal);
                  })));
    });
  }

  /// Shows the deadline in the right format for the GoalTile.
  String _showDeadline(DateTime? deadline) {
    String deadlineTextformat = (deadline == null)
        ? ""
        : (deadline.hour == 0 && deadline.minute == 0)
            ? DateFormat('dd.MM.yy').format(deadline)
            : DateFormat('dd.MM.yy - HH:mm').format(deadline);

    return deadlineTextformat;
  }

  /// Makes sure the expanded tiles stay expanded after switching pages.
  @override
  bool get wantKeepAlive => true;

  /// Turn string reminder into a duration.
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

  /// Long pressing a GoalTile will (un)mark the goal as completed.
  void _onLongPressGoalTile(Goal goal) {
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
}
