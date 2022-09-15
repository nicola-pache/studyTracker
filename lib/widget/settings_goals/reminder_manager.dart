import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/page/calendar.dart';
import 'package:untitled/page/goals.dart';
import 'package:untitled/page/startpage.dart';
import 'package:untitled/widget/reminder_picker.dart';
import '../../notification_services.dart';
import '../date_time_picker.dart';
import '../goal_dialog.dart';

/// ReminderManager as a stateful widget, part 1.
/// Creates the state of the ReminderManager.
///
/// The ReminderManager contains a notifier [countGoalsWithReminder]
/// for changes in the number of goals with a reminder.
class ReminderManager extends StatefulWidget {
  const ReminderManager({Key? key}) : super(key: key);

  static ValueNotifier<int> countGoalsWithReminder = ValueNotifier<int>(0);

  @override
  _SettingsReminderState createState() => _SettingsReminderState();
}

/// Handles the state of the ReminderManager.
/// This widget shows a listTile for managing reminders.
class _SettingsReminderState extends State<ReminderManager> {
  /// Counts all goals with a reminder.
  void _countGoalsWithReminder(HiveList<Goal> goalList) {
    int _count = 0;
    for (int i = 0; i < GoalsList.goals.length; i++) {
      if (GoalsList.goals[i].reminder != "Keine Erinnerung" &&
          GoalsList.goals[i].reminder != null &&
          GoalsList.goals[i].isCompleted != true) {
        _count++;
      }
    }
    ReminderManager.countGoalsWithReminder.value = _count;
  }

  /// Builds the ReminderManager listTile view.
  ///
  /// Contains the number of goals with a reminder
  /// and the option to show the dialog for managing reminders.
  @override
  Widget build(BuildContext context) {
    _countGoalsWithReminder(GoalsList.goals);
    return ValueListenableBuilder<int>(
        valueListenable: ReminderManager.countGoalsWithReminder,
        builder: (context, value, _) {
          return ListTile(
            title: Text("Erinnerungen verwalten"),
            subtitle: Text("Anzahl: " +
                ReminderManager.countGoalsWithReminder.value.toString()),
            trailing: Icon(Icons.alarm,
                color: Theme.of(context).colorScheme.onSurface),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            onTap: () {
              // Opens the reminder manager view
              return _showReminderManager();
            },
          );
        });
  }

  /// Shows the ReminderManager dialog.
  ///
  /// Contains a ReminderList with a listView of all reminders.
  _showReminderManager() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Erinnerungen verwalten'),
              content: (ReminderManager.countGoalsWithReminder.value > 0)
                  ? ReminderList()
                  : Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Text("Keine Erinnerungen vorhanden.",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4)))),
              actions: <Widget>[
                TextButton(
                    child: const Text('ZURÜCK', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }
}

/// ReminderList as a stateful widget, part 1.
/// Creates the state of the ReminderList.
///
/// The ReminderList contains a list of all goals with a reminder.
class ReminderList extends StatefulWidget {
  const ReminderList({Key? key}) : super(key: key);

  @override
  _ReminderListState createState() => _ReminderListState();
}

/// Handles the state of the ReminderList.
/// This widget shows a dialog with a list of all goals with a reminder.
class _ReminderListState extends State<ReminderList>
    with AutomaticKeepAliveClientMixin {
  List<Goal> _goalsWithReminder = [];

  /// Creates a list with all goals with a reminder.
  List<Goal> _getGoalsWithReminder() {
    _goalsWithReminder.clear();
    for (int i = 0; i < GoalsList.goals.length; i++) {
      if (GoalsList.goals[i].reminder != "Keine Erinnerung" &&
          GoalsList.goals[i].reminder != null &&
          GoalsList.goals[i].isCompleted != true) {
        _goalsWithReminder.add(GoalsList.goals[i]);
      }
    }

    return _goalsWithReminder;
  }

  /// Builds a list of ReminderTiles.
  @override
  Widget build(BuildContext context) {
    _goalsWithReminder = _getGoalsWithReminder();
    super.build(context);
    return SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 3,
        child: Scrollbar(
            isAlwaysShown: true,
            interactive: true,
            child: ValueListenableBuilder<bool>(
                valueListenable: GoalsList.changeToGoalsList,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: _goalsWithReminder.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildReminderTile(index);
                    },
                  );
                })));
  }

  /// Builds the tile for a goal with reminder.
  ///
  /// A single tile consists of the goals color and name, the deadline and reminder,
  /// as well as the button for editing the reminder and deadline.
  Widget _buildReminderTile(int index) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      Goal goal = _goalsWithReminder[index];
      return Card(
          child: Container(
              decoration: BoxDecoration(
                  border:
                      Border(left: BorderSide(width: 12.0, color: goal.color))),
              child: ListTile(
                  title: Text((goal.reminder!.contains("Minuten"))
                      ? DateFormat('dd.MM.yy - HH:mm').format(goal.deadline!) +
                          "\n" +
                          (goal.reminder!).replaceAll("vorher", "v.")
                      : DateFormat('dd.MM.yy - HH:mm').format(goal.deadline!) +
                          "\n" +
                          (goal.reminder!)),
                  subtitle: Text(goal.name),
                  trailing: IconButton(
                      icon: Icon(Icons.create),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              DateTime? _oldDeadline = (goal.deadline);

                              return EditDialog(
                                  context: context,
                                  goal: goal,
                                  onSave: (Goal goal) {
                                    setState(() {});
                                    goal.save();
                                    GoalsList.updateGoals();

                                    if (goal.deadline != _oldDeadline) {
                                      Calendar.updateCalendarEvents(
                                          oldDeadline: _oldDeadline,
                                          goal: goal);
                                    }

                                    Startpage.reloadGoals.value =
                                        !Startpage.reloadGoals.value;
                                    _getGoalsWithReminder();
                                  });
                            });
                      }))));
    });
  }

  /// Makes sure the expanded tiles stay expanded after switching pages.
  @override
  bool get wantKeepAlive => true;
}

/// EditDialog as a statelessWidget.
///
/// The EditDialog requires a [context] and a [goal] to edit this reminder and deadline.
/// The [onSave] function is needed to save the changes after editing.
class EditDialog extends StatelessWidget {
  EditDialog(
      {required this.context,
      required this.goal,
      required this.onSave,
      Key? key})
      : super(key: key);
  final BuildContext context;
  final Goal goal;
  final void Function(Goal) onSave;

  @override
  Widget build(BuildContext context) {
    return _showEditDialog();
  }

  /// Shows the EditDialog.
  ///
  /// Contains the option to change and delete the reminder and deadline,
  /// as well as to cancel all changes.
  _showEditDialog() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Currently selected reminder of reminder picker.
    String? _selectedReminder = goal.reminder;

    // Sets the currently selected reminder of reminder picker.
    void _setReminder(String reminder) {
      _selectedReminder = reminder;
    }

    // Creates a date time picker.
    SelectReminder _reminderPicker =
        SelectReminder(goal.reminder, _setReminder);

    // Currently selected deadline of deadline Picker.
    ValueNotifier<String> _selectedDeadline =
        ValueNotifier((goal.deadline == null) ? "" : goal.deadline.toString());

    // Sets the currently selected date time of date time picker.
    void _setDateTime(String deadline) {
      _selectedDeadline.value = deadline;
    }

    // Creates a date time picker.
    SelectDateTime _dateTimePicker = SelectDateTime(
        (goal.deadline == null) ? "" : goal.deadline.toString(), _setDateTime);

    // Helper for reminder notifications.
    var notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

    return AlertDialog(
        title: Text("Erinnerungen bearbeiten"),
        content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[_dateTimePicker, _reminderPicker]))),
        actions: [
          TextButton(
            child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
              _formKey.currentState!.reset();
            },
          ),
          TextButton(
              child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                GoalDialog.validator.value = validateReminder(
                    _selectedDeadline.value, _selectedReminder);

                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (goal.reminder != _selectedReminder) {
                    if (_selectedReminder == "Keine Erinnerung") {
                      // Delete notification
                      notifyHelper.deleteNotification(
                          _getIdFromCreationDate(goal.creationDate));
                      ReminderManager.countGoalsWithReminder.value--;
                    } else {
                      // Schedule/change notification
                      notifyHelper.scheduledNotification(
                          _getIdFromCreationDate(goal.creationDate),
                          DateTime.parse(_selectedDeadline.value),
                          _getDuration(_selectedReminder!),
                          "Erinnerung für: " + goal.name,
                          "Hallo! Vergiss nicht \"" +
                              goal.name +
                              "\" in " +
                              (_selectedReminder.toString())
                                  .replaceAll(" vorher", "") +
                              ".",
                          "TestPayload",
                          context);
                    }
                    goal.reminder = _selectedReminder;
                  }

                  if (_selectedDeadline.value == "Kein Fälligkeitsdatum" ||
                      _selectedDeadline.value == "") {
                    goal.deadline = null;
                  } else {
                    goal.deadline = DateTime.parse(_selectedDeadline.value);
                  }
                  onSave(goal);
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                }
              })
        ]);
  }

  /// Validates the reminder textFormField.
  String validateReminder(String deadline, String? reminder) {
    String validatorText = deadline;
    if (reminder != "Keine Erinnerung" && reminder != null) {
      // Reminder selected but no deadline.
      if (deadline == "") {
        validatorText = "Deadline Leer";
      } else {
        // Reminder and deadline selected but notification accures after the deadline.
        if ((DateTime.now().add(_getDuration(reminder)))
            .isAfter(DateTime.parse(deadline))) {
          validatorText = "Erinnerung nach Fälligkeitsdatum";
        }
      }
    }
    return validatorText;
  }

  /// Turns a string reminder into a Duration.
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
}
