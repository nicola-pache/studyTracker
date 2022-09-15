import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/model/modules_model.dart';

import 'goal_dialog.dart';

/// SelectTemplate as a stateless widget.
/// Creates the state of the SelectTemplate.
///
/// SelectTemplate needs a [templatesChanged] notifier to change the list by request.
/// Requires [templates] and [_modulesBox] for access to all templates and related modules.
class SelectTemplate extends StatelessWidget {
  SelectTemplate({Key? key}) : super(key: key);

  /// Causes the list to change if told to.
  static final ValueNotifier<bool> templatesChanged =
      ValueNotifier<bool>(false);

  /// The list of templates as a HiveList.
  /// The list is initialized in goals.dart, to avoid it being initialized
  /// everytime the template manager is opened.
  static final HiveList<Goal> templates =
      HiveList(Hive.box<Goal>('goalsTemplates'));

  /// simplifies the access to the modules HiveBox
  final Box<Module> _modulesBox = Hive.box<Module>('modules');

  /// The template picker must be opened through an iconButton.
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.bookmarks),
        onPressed: () {
          _showTemplatePicker(context);
        });
  }

  /// Shows the template picker.
  _showTemplatePicker(BuildContext context) {
    // build the list tile which opens the listView with the templates.
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Vorlage auswählen'),
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
                                  .withOpacity(0.4)))),
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

  /// List of templates to choose from.
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
                            contentPadding: const EdgeInsets.all(5.0),
                            leading: Container(
                              alignment: Alignment.centerLeft,
                              width: 12,
                              height: 55,
                              color: _template.color,
                            ),
                            title: Text(_templateName,
                                style: TextStyle(fontSize: 18)),
                            subtitle: Text(_templateModuleName),
                            trailing: Icon(Icons.arrow_forward_ios_outlined,
                                color: Theme.of(context).colorScheme.onSurface),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();

                              _addGoal(context: context, template: _template);
                            });
                      });
                })));
  }

  /// Add a new goal from a template.
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
              onSave: (Goal goal) {});
        });
  }
}
