import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:untitled/page/goals.dart';
import 'package:untitled/widget/settings_goals/reminder_manager.dart';
import 'package:untitled/widget/sorting_manager.dart';
import 'package:untitled/widget/settings_goals/template_manager.dart';

import '../filter_manager.dart';

/// SettingsButtonGoals as a stateful widget, part 1.
/// Creates the state of the SettingsButtonGoals.
class SettingsButtonGoals extends StatefulWidget {
  const SettingsButtonGoals({Key? key}) : super(key: key);

  @override
  _SettingsButtonGoalsState createState() => _SettingsButtonGoalsState();
}

/// Handles the state of the SettingsButtonGoals.
/// This widget shows a dialog with related settings to goals.
class _SettingsButtonGoalsState extends State<SettingsButtonGoals> {
  /// Builds a SettingsButten.
  /// The SettingsButton opens a dialog with related settings to goals.
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _showSettingsDialog();
            });
      },
      icon: Icon(
        Icons.dehaze,
        size: 35.0,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text("    EINSTELLUNGEN"),
    );
  }

  /// Creates a SortingManager.
  SortingManager _sortingManager = SortingManager(
      sortOrders:
          // Possible sort orders with the german labels mapped to the variable names.
          {
        "nameDescending": "Name absteigend",
        "nameAscending": "Name aufsteigend",
        "deadlineDescending": "Deadline absteigend",
        "deadlineAscending": "Deadline aufsteigend",
        "creationDateDescending": "Erstellungsdatum absteigend",
        "creationDateAscending": "Erstellungsdatum aufsteigend"
      },
      onSave: (String selectedSortOrder) {
        Hive.box('settings').put('goalsSortOrder', selectedSortOrder);
        GoalsList.updateGoals();
      },
      dialogTitle: "Ziele sortieren",
      boxName: 'goalsSortOrder');

  /// Creates a FilterManager.
  FilterManager _filterManager = FilterManager(
      filters:
          // Possible filters with the german labels mapped to the variable names.
          {
        "all": "Alle Ziele",
        "openGoals": "Offene Ziele",
        "completedGoals": "Abgeschlossene Ziele"
      },
      filterName: 'goalsFilter',
      onSave: (String selectedFilter) {
        Hive.box('settings').put('goalsFilter', selectedFilter);
        GoalsList.updateGoals();
      },
      dialogTitle: "Ziele filtern");

  /// Creates a ReminderManager.
  ReminderManager _reminderManager = ReminderManager();

  /// Shows a dialog to access the settings of the goals:
  /// sorting, filters, templates and reminders.
  Widget _showSettingsDialog() {
    return AlertDialog(
        title: Text("Einstellungen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _sortingManager,
            Divider(
                thickness: 1.0,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            _filterManager,
            Divider(
                thickness: 1.0,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            TemplateManager(),
            Divider(
                thickness: 1.0,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            _reminderManager,
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ZURÜCK', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ]);
  }
}
