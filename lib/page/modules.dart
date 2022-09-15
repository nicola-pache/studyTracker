import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widget/module_dialog.dart';
import 'package:untitled/widget/settings_button_modules.dart';
import 'package:untitled/widget/timer_button.dart';
import '../page_navigation.dart';
import 'single_module.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:hive/hive.dart';

/// List of modules as stateful widget, part 1. It creates the state for
/// the modules list.
class ModulesList extends StatefulWidget {
  ModulesList({Key? key}) : super(key: key);

  /// a HiveList of the modules which are displayed in this widget;
  /// changes of modules in the box will also affect the modules in the HiveList
  static HiveList<Module> modules = HiveList(Hive.box<Module>('modules'));

  /// Changes to the modules list reload the list.
  static ValueNotifier<bool> resetModuleList = ValueNotifier<bool>(false);

  /// Resorts and filters the modules list after it has been changed.
  static void updateModules() {
    _filterModules();
    ModulesList.modules.sort(Module.moduleComparator());
    ModulesList.resetModuleList.value = !ModulesList.resetModuleList.value;
  }

  /// Filters the modules.
  static void _filterModules() {
    String _currentlySelectedFilter = Hive.box('settings').get('modulesFilter');
    ModulesList.modules.clear();
    if (_currentlySelectedFilter == 'openModules') {
      ModulesList.modules.addAll(Hive.box<Module>('modules')
          .values
          .where((module) => !module.isClosed)
          .toList());
    } else if (_currentlySelectedFilter == 'closedModules') {
      ModulesList.modules.addAll(Hive.box<Module>('modules')
          .values
          .where((module) => module.isClosed)
          .toList());
    } else {
      ModulesList.modules.addAll(Hive.box<Module>('modules').values.toList());
    }
  }

  @override
  _ModulesListState createState() => _ModulesListState();
}

/// List of modules as stateful widget, part 2. Builds the actual modules list.
class _ModulesListState extends State<ModulesList>
    with AutomaticKeepAliveClientMixin {

  /// The HiveBox with the modules: for easier reference
  Box modulesBox = Hive.box<Module>('modules');

  /// Initializes the moduleList widget
  @override
  void initState() {
    super.initState();
    // add the modules from the HiveBox to the HiveList and sort/filter them
    ModulesList.modules.addAll(Hive.box<Module>('modules').values.toList());
    ModulesList._filterModules();
    ModulesList.modules.sort(Module.moduleComparator());
  }

  /// Builds a list of ModuleTiles
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: SettingsButtonModules(),
          centerTitle: false,
          actions: <Widget>[
            Container(
                padding: EdgeInsets.only(right: 20.0),
                child: IconButton(
                    icon: Icon(Icons.add_circle, size: 40.0, semanticLabel: "Modul hinzufügen",),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return ModuleDialog(
                                context: context,
                                onSave: (Module module) {
                                  modulesBox.put(module.creationDate, module);
                                  ModulesList.modules.add(module);
                                  ModulesList.updateModules();
                                });
                          });
                    }))
          ],
        ),
        body: ValueListenableBuilder(
            builder: (BuildContext context, bool value, _) {
              return ListView.builder(
                itemCount: ModulesList.modules.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildModuleTile(index);
                },
              );
            },
            valueListenable: ModulesList.resetModuleList));
  }

  /// Builds the list tile for a module.
  Widget _buildModuleTile(int index) {
    Module module = ModulesList.modules[index];
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Card(
          child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(5.0),
              // adds a colored bar on the left side of a tile
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(width: 12.0, color: module.color))),
              child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SingleModule(
                          module: module, onChange: () => setState(() {}));
                    }));
                  },
                  title: Text(module.abbreviation,
                      style: const TextStyle(fontSize: 25), maxLines: 2),
                  subtitle: Text(_openGoalsText(module)),
                  trailing: module.isClosed
                      // Icon to mark a goal as completed
                      ? Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: module.color),
                          constraints:
                              BoxConstraints.tightForFinite(width: 105),
                          child: Icon(
                            Icons.lock_outline, semanticLabel: "Modul ist abgeschlossen",
                            color: Theme.of(context).colorScheme.surface,
                            size: 34,
                          ))
                      // Button for the timer
                      : ValueListenableBuilder<bool>(
                          builder: (context, value, _) {
                            return TimerButton(
                                context, [1, module.creationDate]);
                          },
                          valueListenable: Navigation.timerActivated))));
    });
  }

  /// Gets the number of open goals of a module and shows them below the
  /// name of the module in the module list.
  String _openGoalsText(Module module) {
    String _openGoalsText;
    int _numberOfOpenGoals = 0;
    module.goals.forEach((goal) {
      if (!goal.isCompleted) {
        _numberOfOpenGoals += 1;
      }
    });
    if (_numberOfOpenGoals == 1) {
      _openGoalsText = "1 offenes Ziel";
    } else if (_numberOfOpenGoals == 0) {
      _openGoalsText = "Keine offenen Ziele";
    } else {
      _openGoalsText = "$_numberOfOpenGoals offene Ziele";
    }
    return _openGoalsText;
  }

  /// Makes sure the expanded tiles stay expanded after switching pages.
  @override
  bool get wantKeepAlive => true;
}
