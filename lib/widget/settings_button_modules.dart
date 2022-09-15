import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:untitled/page/modules.dart';
import 'package:untitled/widget/sorting_manager.dart';
import 'package:untitled/widget/filter_manager.dart';

/// Creates the settings button for the modules.
class SettingsButtonModules extends StatelessWidget {
  SettingsButtonModules({Key? key}) : super(key: key);

  /// Builds a SettingsButton.
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _showSettingsDialog(context);
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

  /// Creates a sorting manager.
  final SortingManager _sortingManager = SortingManager(
      sortOrders:
      // Possible sort orders with the german labels mapped to the variable names
      {
        "nameDescending" : "Name absteigend",
        "nameAscending" : "Name aufsteigend",
        "abbreviationDescending" : "Kürzel absteigend",
        "abbreviationAscending" : "Kürzel aufsteigend",
        "creationDateDescending" : "Erstellungsdatum absteigend",
        "creationDateAscending" : "Erstellungsdatum aufsteigend"
      },
      onSave: (String selectedSortOrder) {
        Hive.box('settings').put('modulesSortOrder', selectedSortOrder);
        ModulesList.updateModules();
      },
      dialogTitle: "Module sortieren",
      boxName: 'modulesSortOrder'
  );

  /// Creates a filter manager.
  final FilterManager _filterManager = FilterManager(
      filters:
      // Possible filters with the german labels mapped to the variable names
      {
        "all" : "Alle Module",
        "openModules" : "Offene Module",
        "closedModules" : "Geschlossene Module"
      },
      filterName: 'modulesFilter',
      onSave: (String selectedFilter) {
        Hive.box('settings').put('modulesFilter', selectedFilter);
        ModulesList.updateModules();
      },
      dialogTitle: "Module filtern"
  );

  /// Shows a dialog to change the settings - sorting, templates, reminders.
  Widget _showSettingsDialog(BuildContext context) {
    return AlertDialog(
        title: Text("Einstellungen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _sortingManager,
            Divider(
                thickness: 1.0,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
            ),
            _filterManager
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