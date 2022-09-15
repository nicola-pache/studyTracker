import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/page/timer.dart';
import 'package:untitled/widget/module_dialog.dart';
import 'package:untitled/widget/module_picker.dart';
import 'modules.dart';
import 'goals.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:hive/hive.dart';
import 'package:untitled/model/goals_model.dart';

/// SingleModule as StatefulWidget, part 1. Creates the state for the widget.
class SingleModule extends StatefulWidget {
  const SingleModule({required this.module, this.onChange, Key? key})
      : super(key: key);

  /// The currently displayed module.
  final Module module;

  /// Says what happens, when changes to the module are made.
  final void Function()? onChange;

  @override
  _SingleModuleState createState() => _SingleModuleState();
}

/// SingleModule as StatefulWidget, part 2. Handles the state of the widget.
class _SingleModuleState extends State<SingleModule> {

  /// Reloads the indicator for a closed module, if the status has changed.
  late final ValueNotifier<bool> _isClosed;

  /// Information about the active timer: if the timer of the current goal
  /// is running, the current goal cannot be deleted
  final List? _activeTimer = Hive.box('timer').get('activeTimer');

  /// Initializes the widget.
  @override
  void initState() {
    super.initState();
    _isClosed = ValueNotifier<bool>(widget.module.isClosed);
  }

  /// Builds the module.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Text(widget.module.abbreviation),
            Expanded(
                child: Divider(
                    thickness: 10.0, indent: 10.0, color: widget.module.color)),
            if (widget.module.creationDate != '0')
              IconButton(
                icon: const Icon(Icons.create, semanticLabel: "Modul bearbeiten",),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        Color oldColor = widget.module.color;
                        return ModuleDialog(
                            context: context,
                            module: widget.module,
                            onSave: (Module module) {
                              if (module.color != oldColor) {
                                Hive.box<Goal>('goals').values.forEach((goal) {
                                  if (goal.module == module.creationDate) {
                                    goal.color = module.color;
                                    goal.save();
                                  }
                                });
                                GoalsList.changeToGoalsList.value =
                                    !GoalsList.changeToGoalsList.value;
                              }
                              module.save();
                              if (widget.onChange != null) widget.onChange!();
                              setState(() {});
                            });
                      });
                },
              ),
            if (widget.module.creationDate != '0')
              IconButton(
                  icon: const Icon(Icons.delete, semanticLabel: "Modul löschen",),
                  onPressed: _activeTimer != null
                      && _activeTimer![0] == 1
                      && _activeTimer![1] == widget.module.creationDate
                      ? null
                      : () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _handleDeletingModule(widget.module);
                            });
                        }),
            if (widget.module.creationDate != '0')
                ValueListenableBuilder<bool>(
                  valueListenable: _isClosed,
                  builder: (context, value, _) {
                  // IconButton to mark the current module as closed/not closed
                  return IconButton(
                      icon: widget.module.isClosed
                          ? Container(
                              decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.module.color),
                              child: Icon(Icons.lock_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface, semanticLabel: "Modul wieder öffnen",))
                          : const Icon(Icons.lock_open_outlined, semanticLabel: "Modul abschließen",),
                      alignment: Alignment.centerRight,
                      onPressed: (widget.module.goals
                          .where((goal) => !goal.isCompleted)
                          .isNotEmpty)
                          ? null
                          : () => _onModuleClose()
                      );
                 }),
          ]),
          backwardsCompatibility: false, // use the specified foreground color
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Container(
            //padding: EdgeInsets.all(15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              if (widget.module.creationDate != '0')
                Card(child: _moduleDescription(context, widget.module)),
              if (widget.module.goals.isNotEmpty) SizedBox(height: 15),
              if (widget.module.goals.isNotEmpty) Text("Offene Ziele",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (widget.module.goals.isNotEmpty) _goalList(widget.module.goals)
            ])));
  }

  /// Shows the list of all open goals of a module.
  Widget _goalList(List<Goal> goals) {
    List<Goal> _listOfGoals =
        widget.module.goals.where((goal) => !goal.isCompleted).toList();
    _listOfGoals.sort(Goal.goalComparator());
    return Expanded(
      child: ListView.builder(
          itemCount: _listOfGoals.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    title: Text(_listOfGoals[index].name,
                        style: const TextStyle(fontSize: 25), maxLines: 2),
                        subtitle: Text(_showDeadline(_listOfGoals[index].deadline))
                ));
          }
    ));
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

  /// Handles closing and opening of a module.
  void _onModuleClose() {
    if (widget.module.isClosed) {
      widget.module.isClosed = false;
      widget.module.save();
      _isClosed.value = false;
      if (widget.onChange != null) {
        widget.onChange!();
      }
      for (Goal goal in widget.module.goals) {
        goal.isArchived = false;
      }
      GoalsList.updateGoals();
    } else {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return _showCloseWarning();
      });
    }
  }

  /// Show a dialog which lets the user decide if the goals should moved to
  /// another module or be deleted; then it shows a delete warning.
  AlertDialog _handleDeletingModule(Module module) {
    String _newModule = '0';
    Color _newColor = Colors.blueGrey;
    return AlertDialog(
        title: const Text ("Ziele einem neuen Modul zuweisen"),
        content: Column(
            children: <Widget>[
              const Text("Bitte wähle ein neues Modul für die Ziele."),
              SelectModule(
                '0',
                (String selectedModule) => _newModule = selectedModule,
                (Color selectedColor) => _newColor = selectedColor,
                omitModule: module,
                additionalEntries: const [{
                  'value': "delete goals",
                  'icon': Icon(Icons.stop, color: Color(0x00000000)),
                  'label': "Ziele löschen"
                }],
              )
            ]
        ),
        actions: [
          TextButton(
            child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('LÖSCHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              _showDeleteWarning(module, _newModule, _newColor);
            },
          ),
        ]
    );
  }

  /// Shows a dialog which informs the user about the consequences of deleting
  /// the module.
  void  _showDeleteWarning(Module module, String newModule, Color newColor) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Modul löschen'),
              content: Text(
                  newModule == 'delete goals'
                      ? 'Achtung: das Modul und die dazugehörigen Ziele werden '
                          'gelöscht!'
                      : 'Achtung: das Modul wird gelöscht, die dazugehörigen '
                          'Ziele werden dem ausgewählten Modul zugeordnet!',
                  style: const TextStyle(fontSize: 18)),
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
                    // goals are deleted or moved to another module
                    if (newModule == 'delete goals') {
                      module.goals.deleteAllFromHive();
                    } else {
                      for (Goal goal in module.goals) {
                        goal.module = newModule;
                        goal.color = newColor;
                        goal.save();
                      }
                      Module _newModule = Hive.box<Module>('modules').get(newModule)!;
                      _newModule.goals.addAll(module.goals);
                      _newModule.save();

                    }
                    Hive.box<Module>('modules').delete(module.creationDate);
                    TimerTabs.deleteModuleFromStatistics(module.creationDate);
                    GoalsList.changeToGoalsList.value =
                      !GoalsList.changeToGoalsList.value;
                    ModulesList.resetModuleList.value =
                      !ModulesList.resetModuleList.value;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ]);
        }
    );
  }

  /// Shows a dialog which informs the user about the consequences of closing
  /// the module.
  AlertDialog _showCloseWarning() {
    return AlertDialog(
        title: const Text('Modul schließen'),
        content: const SingleChildScrollView(
            child: Text(
                'Hinweis: Das Modul und dazugehörige Ziele werden geschlossen und '
                    'archiviert. Zum geschlossenen Modul können keine neuen Ziele '
                    'hinzugefügt werden.',
                style: TextStyle(fontSize: 18))),
        actions: <Widget>[
          TextButton(
            child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('MODUL SCHLIESSEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              widget.module.isClosed = true;
              widget.module.save();
              _isClosed.value = true;
              if (widget.onChange != null) {
                widget.onChange!();
              }
              widget.module.goals.forEach((goal) {
                goal.isArchived = true;
              });
              GoalsList.updateGoals();
              Navigator.of(context).pop();
            },
          )
        ]);
  }

  /// Formats the module description.
  Widget _moduleDescription(BuildContext context, Module module) {
    return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(10.0),
        child: RichText(
            text: TextSpan(
                style: (TextStyle(
                    fontSize: 20.0,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                    fontWeight: FontWeight.normal)),
                children: <TextSpan>[
              const TextSpan(
                  text: 'Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold, height: 1.0)),
              TextSpan(text: module.name),
              const TextSpan(
                  text: '\nLehrperson: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: module.teacher ?? '-'),
              const TextSpan(
                  text: '\nSemester: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: module.semester ?? '-'),
              const TextSpan(
                  text: '\nCredits: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: module.credits ?? '-'),
              const TextSpan(
                  text: '\nAnmerkung: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: module.notes ?? '-')
            ])));
  }
}
