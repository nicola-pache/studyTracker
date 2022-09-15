import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/model/modules_model.dart';
import '../goal_dialog.dart';

/// Template manager as stateless widget, part 1.
class TemplateManager extends StatelessWidget {
  TemplateManager({Key? key}) : super(key: key);

  /// Causes the list to change if necessary.
  static final ValueNotifier<bool> templatesChanged = ValueNotifier<bool>(false);

  /// The list of templates as a HiveList.
  ///
  /// The list is initialized in goals.dart, to avoid it being initialized
  /// everytime the template manager is opened.
  static final HiveList<Goal> templates = HiveList(Hive.box<Goal>('goalsTemplates'));

  /// Simplifies the access to the modules HiveBox.
  final Box<Module> _modulesBox = Hive.box<Module>('modules');

  /// Builds the template manager view.
  @override
  Widget build(BuildContext context) {
    // build the list tile which opens the listView with the templates
    return ListTile(
      title: Text("Vorlagen verwalten"),
      subtitle: ValueListenableBuilder(
        valueListenable: templatesChanged,
        builder: (BuildContext context, bool value, _) {
            return Text("Anzahl: ${templates.length}");
        }),
      trailing: Icon(Icons.bookmarks, color: Theme.of(context)
          .colorScheme
          .onSurface),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      onTap: () {
        return _showTemplateManager(context);
      },
    );
  }

  /// Creates the template manager.
  void _showTemplateManager(BuildContext context) {
    // Shows a dialog with all templates
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Vorlagen verwalten'),
                    IconButton(
                      icon: Icon(Icons.add,
                          color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        _addTemplate(context);
                      }
                    )
                  ]),
              content: templates.length > 0
                  ? _listTemplates(context)
                  : Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Text("Keine Vorlagen vorhanden.",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4)
                          ))),
              actions: <Widget>[
                TextButton(
                  child: Text('ZURÜCK', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
  }

  /// Lists the templates.
  /// Each template can be edited and deleted.
  Widget _listTemplates(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 3,
        child: Scrollbar(
            isAlwaysShown: true,
            interactive: true,
            child: ValueListenableBuilder(
              valueListenable: templatesChanged,
              builder: (BuildContext context, bool value, _) {
                return ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (BuildContext context, int index) {
                      Goal _template = templates[index];
                      String _templateName = _template.name;
                      String _templateModuleName =
                          _modulesBox.get(_template.module)!.name;
                      return ListTile(
                          title: Text(_templateName,
                              style: TextStyle(fontSize: 18)),
                          subtitle: Text(_templateModuleName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget> [
                              IconButton(
                                icon: Icon(Icons.create),
                                onPressed: () {
                                  _changeTemplate(
                                    context: context,
                                    template: _template,
                                    oldName: _templateName,
                                    oldModule: _templateModuleName
                                  );
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteWarning(context,
                                        _template.creationDate);
                                  }
                              )
                            ]
                          ),
                          onTap: () {
                            _addGoal(context: context, template: _template);
                          }
                      );
                    }
                );
              })));
  }

  /// Shows a delete warning.
  void _showDeleteWarning(BuildContext context, String creationDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Vorlage löschen'),
              content: const Text(
                  'Soll die Vorlage wirklich gelöscht werden?',
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
                    Hive.box<Goal>('goalsTemplates').delete(creationDate);
                    templatesChanged.value = !templatesChanged.value;
                    Navigator.of(context).pop();

                  },
                )
              ]);
      }
    );
  }

  /// Lets the user add a template.
  void _addTemplate(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GoalDialog(
              context: context,
              title: "Vorlage hinzufügen",
              isTemplate: true,
              onSave: (Goal template) {
                Hive.box<Goal>('goalsTemplates')
                    .put(template.creationDate, template);
                templates.add(template);
                templates.sort((a, b) => a.name.compareTo(b.name));
                templatesChanged.value = !templatesChanged.value;
              });
        });
  }

  /// Lets the user change a template.
  void _changeTemplate({required BuildContext context, required Goal template,
    required String oldName, required String oldModule}) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GoalDialog(
              context: context,
              title: "Vorlage bearbeiten",
              isTemplate: true,
              goal: template,
              onSave: (Goal template) {
                template.save();
                if (template.name != oldName) {
                  templates.sort((a, b) => a.name.compareTo(b.name));
                }
                if (template.name != oldName ||
                    template.module != oldModule) {
                  templatesChanged.value = !templatesChanged.value;
                }
              });
        });
  }

  /// Adds a goal from a template.
  void _addGoal({required BuildContext context, required Goal template}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GoalDialog(
              context: context,
              title: "Ziel hinzufügen",
              isTemplate: true,
              saveTemplateAsGoal: true,
              goal: template,
              onSave: (Goal goal) {
              });
        });
  }
}
