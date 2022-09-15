import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/notification_services.dart';
import 'package:untitled/page/calendar.dart';
import 'package:untitled/page/goals.dart';
import 'package:untitled/widget/color_picker.dart';
import 'package:untitled/widget/module_picker.dart';
import 'package:untitled/widget/reminder_picker.dart';
import 'package:untitled/widget/date_time_picker.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:untitled/widget/settings_goals/template_manager.dart';
import 'package:untitled/widget/template_picker.dart';

import 'estimatedTime_picker.dart';

/// GoalDialog as a stateless widget.
/// Creates the state of the GoalDialog.
///
/// GoalDialog requires a [context] for navigation.
/// It also needs a [goal] which gets created or edited.
/// The current operation can be recognized by the [title].
/// Changes to this goal will be saved in [onSave].
///
/// Its possible for a goal to be a template [isTemplate].
/// With [saveTemplateAsGoal] can a template be saved as a goal.
///
/// The notifier [validator] listens for changes for textFormField in reminder picker.
class GoalDialog extends StatelessWidget {
  const GoalDialog(
      {required this.context,
      required this.onSave,
      this.goal,
      required this.title,
      required this.isTemplate,
      this.saveTemplateAsGoal,
      Key? key})
      : super(key: key);

  /// Current context.
  final BuildContext context;

  /// Saves the changes to a goal.
  final void Function(Goal) onSave;

  /// Current goal.
  final Goal? goal;

  /// Titel to specialize, if a new goal is created or an existing one edited.
  final String title;

  /// True, if this goal is a template.
  final bool isTemplate;

  /// Saves a template as goal.
  final bool? saveTemplateAsGoal;

  /// Validator for textFormField in reminder picker.
  static ValueNotifier<String> validator = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return _showGoalDialog();
  }

  /// Shows a dialog to add or edit a goal.
  /// Parameter index is optional.
  _showGoalDialog() {
    // Key to identify the state of the form and validate the inputs.
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Goal is created if it doesn't exist already.
    Goal goal =
        this.goal ?? Goal(creationDate: DateTime.now().toUtc().toString());

    // Currently selected estimatedTime of estimatedTime picker.
    Duration? _selectedEstimatedTime = goal.estimatedTime;

    // Sets the currently selected estimatedTime of estimatedTime picker.
    void _setEstimatedTime(Duration? estimatedTime) {
      _selectedEstimatedTime = estimatedTime;
    }

    // Creates an estimatedTime picker.
    SelectEstimatedTime _estimatedTimePicker =
        SelectEstimatedTime(goal.estimatedTime, _setEstimatedTime);

    // Currently selected reminder of reminder picker.
    String? _selectedReminder = goal.reminder;

    // Sets the currently selected reminder of reminder picker.
    void _setReminder(String reminder) {
      _selectedReminder = reminder;
    }

    // Creates a date time picker.
    SelectReminder _reminderPicker =
        SelectReminder(goal.reminder, _setReminder);

    // Currently selected color of color picker.
    Color _selectedColor = goal.color;

    // Sets the currently selected color of color picker.
    void _setColor(Color color) {
      _selectedColor = color;
    }

    // Creates a color picker, default color is the module's color.
    SelectColor _colorPicker = SelectColor(goal.color, _setColor);

    // Currently selected deadline of deadline picker.
    ValueNotifier<String> _selectedDeadline =
        ValueNotifier((goal.deadline == null) ? "" : goal.deadline.toString());

    // Sets the currently selected date time of date time picker.
    void _setDateTime(String deadline) {
      _selectedDeadline.value = deadline;
    }

    // Creates a date time picker.
    SelectDateTime _dateTimePicker = SelectDateTime(
        (goal.deadline == null) ? "" : goal.deadline.toString(), _setDateTime);

    // Currently selected module of module picker.
    ValueNotifier<String> _selectedModule = ValueNotifier(goal.module);

    // Sets the currently selected module of module picker.
    void _setModule(String module) {
      _selectedModule.value = module;
    }

    // Creates a module picker.
    SelectModule _modulePicker =
        SelectModule(goal.module, _setModule, _setColor);

    // Checks if the goal should be saved as a template.
    bool _willBeTemplate = false;

    // Helper for reminder notifications.
    var notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

    // Shows form in an alert dialog.
    return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            // Creates a template picker.
            SelectTemplate()
          ],
        ),
        content: Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      autofocus: false,
                      initialValue: goal.name,
                      style: const TextStyle(fontSize: 18),
                      decoration: _decorateTextField('Name'),
                      validator: (String? value) {
                        String? errorMsg;
                        if (value == null || value.isEmpty) {
                          errorMsg = 'Bitte geben Sie einen Namen an.';
                        }
                        return errorMsg;
                      },
                      onSaved: (String? value) {
                        goal.name = value!;
                      },
                    ),
                    _estimatedTimePicker,
                    _dateTimePicker,
                    ValueListenableBuilder(
                        valueListenable: _selectedDeadline,
                        builder: (BuildContext context, value, _) {
                          return Container(
                              child: (_selectedDeadline != "")
                                  ? _reminderPicker
                                  : null);
                        }),
                    _modulePicker,
                    Text("Modul",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            height: 1.75)),
                    TextFormField(
                      initialValue: goal.notes,
                      style: const TextStyle(fontSize: 18),
                      decoration: _decorateTextField('Anmerkungen'),
                      onSaved: (String? value) {
                        goal.notes = value!;
                      },
                    ),
                    // ColorPicker
                    ValueListenableBuilder(
                        valueListenable: _selectedModule,
                        builder: (BuildContext context, value, _) {
                          return _selectedModule.value == '0' ||
                                  _selectedModule.value == ''
                              ? _colorPicker
                              : Column(
                                  children: [
                                    Text("",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color:
                                                Color.fromRGBO(3, 3, 3, 97))),
                                    Row(
                                      children: [
                                        Icon(Icons.color_lens,
                                            size: 40,
                                            color: Hive.box<Module>('modules')
                                                .get(_selectedModule.value)!
                                                .color),
                                        Expanded(
                                            child: Text('Modulfarbe übernommen',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.6),
                                                    fontWeight:
                                                        FontWeight.normal)))
                                      ],
                                    ),
                                    Text("",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color:
                                                Color.fromRGBO(3, 3, 3, 97))),
                                  ],
                                );
                        }),
                    if (!isTemplate)
                      Divider(
                          thickness: 1.0,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4)),
                    if (!isTemplate)
                      StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return CheckboxListTile(
                          title: Text("Dieses Ziel als Vorlage speichern?",
                              semanticsLabel: (_willBeTemplate)
                                  ? "Dieses Ziel als Vorlage speichern? Aktuelle Auswahl: Ja"
                                  : "Dieses Ziel als Vorlage speichern? Aktuelle Auswahl: Nein",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6))),
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: _willBeTemplate,
                          onChanged: (value) {
                            setState(() {
                              _willBeTemplate = value!;
                            });
                          },
                        );
                      })
                  ],
                ),
              )),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
              _colorPicker = SelectColor(goal.color, _setColor);
              _formKey.currentState!.reset();
            },
          ),
          TextButton(
              child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                validator.value = validateReminder(
                    _selectedDeadline.value, _selectedReminder);

                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  goal.estimatedTime = _selectedEstimatedTime;

                  if (goal.reminder != _selectedReminder ||
                      goal.deadline != null &&
                          goal.deadline !=
                              DateTime.parse(_selectedDeadline.value)) {
                    if (_selectedReminder == "Keine Erinnerung" ||
                        _selectedReminder == null) {
                      notifyHelper.deleteNotification(
                          _getIdFromCreationDate(goal.creationDate));
                    } else {
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
                          "payload",
                          context);
                    }
                    goal.reminder = _selectedReminder;
                  }

                  goal.module = _selectedModule.value;
                  goal.color = _selectedColor;
                  if (_selectedDeadline.value == "Kein Fälligkeitsdatum" ||
                      _selectedDeadline.value == "") {
                    goal.deadline = null;
                  } else {
                    goal.deadline = DateTime.parse(_selectedDeadline.value);
                  }
                  if (_willBeTemplate) {
                    _saveGoalAsTemplate(goal);
                  }
                  if (saveTemplateAsGoal ?? false) {
                    _saveTemplateAsGoal(goal);
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
        // Reminder and deadline selected but notification accrues after the deadline.
        if ((DateTime.now().add(_getDuration(reminder)))
            .isAfter(DateTime.parse(deadline))) {
          validatorText = "Erinnerung nach Fälligkeitsdatum";
        }
      }
    }
    return validatorText;
  }

  /// Turns String reminder into a duration.
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

  /// Gets the id for the notification from a goals creationDate.
  int _getIdFromCreationDate(String creationDate) {
    String idString =
        (creationDate.replaceAll(RegExp('[^0-9]'), '')).substring(4, 14);
    int idInt = int.parse(idString);

    return idInt;
  }

  /// Formats the text field of the form.
  InputDecoration _decorateTextField(String name) {
    return (InputDecoration(
        helperStyle: const TextStyle(fontSize: 18),
        helperMaxLines: 2,
        helperText: name,
        errorMaxLines: 5));
  }
}

/// Transforms a goal into a template, because the box for the goals and the
/// box for templates cannot have the same instance of a goal.
void _saveGoalAsTemplate(Goal goal) {
  Goal _template = Goal();
  _template
    ..name = goal.name
    ..estimatedTime = goal.estimatedTime
    ..deadline = goal.deadline
    ..reminder = goal.reminder
    ..module = goal.module
    ..notes = goal.notes
    ..timeLearned = goal.timeLearned
    ..color = goal.color
    ..isCompleted = goal.isCompleted
    ..creationDate = DateTime.now().toString();
  Hive.box<Goal>('goalsTemplates').put(_template.creationDate, _template);
  TemplateManager.templates.add(_template);
  TemplateManager.templates.sort((a, b) => a.name.compareTo(b.name));
  SelectTemplate.templates.add(_template);
  SelectTemplate.templates.sort((a, b) => a.name.compareTo(b.name));
}

/// Transforms a template into a goal, because the box for the goals and the
/// box for templates cannot have the same instance of a goal.
void _saveTemplateAsGoal(Goal template) {
  Goal _goal = Goal()
    ..name = template.name
    ..estimatedTime = template.estimatedTime
    ..deadline = template.deadline
    ..reminder = template.reminder
    ..module = template.module
    ..notes = template.notes
    ..timeLearned = template.timeLearned
    ..color = template.color
    ..isCompleted = template.isCompleted
    ..creationDate = DateTime.now().toString();
  Hive.box<Goal>('goals').put(_goal.creationDate, _goal);
  GoalsList.goals.add(_goal);
  GoalsList.goals.sort(Goal.goalComparator());
  GoalsList.changeToGoalsList.value = !GoalsList.changeToGoalsList.value;
  Module module = Hive.box<Module>('modules').get(_goal.module)!;
  module.goals.add(_goal);
  module.save();
  Calendar.updateCalendarEvents(goal: _goal);
}
