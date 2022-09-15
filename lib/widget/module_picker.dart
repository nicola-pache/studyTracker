import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Import requires including the select_form_field-package in the pubspec.yaml!
import 'package:select_form_field/select_form_field.dart';
import 'package:untitled/model/modules_model.dart';

/// SelectModule as a stateless widget.
/// Creates the state of the SelectModule.
///
/// The SelectModule requires a [_defaultModule] to access the current module
/// and the function [_setModule] to set a new module.
/// [_setColor] updates the color, if a the [_defaultModule] changes.
///
/// When a module gets deleted there is the option to move all goals to another
/// module, or to delete the goals as well [additionalEntries].
/// The module that gets deleted [omitModule] will not be shown in the module picker.
class SelectModule extends StatelessWidget {
  const SelectModule(this._defaultModule, this._setModule, this._setColor,
      {this.additionalEntries, this.omitModule, Key? key})
      : super(key: key);

  /// Current module.
  final String _defaultModule;

  /// Sets a new module.
  final Function _setModule;

  /// Updates the color if the module changes.
  final Function _setColor;

  /// Contains additional entries to delete all goals related to a module
  /// that gets deleted.
  final List<Map<String, dynamic>>? additionalEntries;

  /// This is not shown in the module picker.
  final Module? omitModule;

  /// Builds a module picker.
  ///
  /// The picker must be opened through a TextFormField.
  /// Contains a searchBar and a list of available modules to pick from.
  /// As well as the option to cancel the selection.
  @override
  Widget build(BuildContext context) {
    String? _currentModuleCreationDate = _defaultModule;

    // Creates the module items for the dropdown menu.
    List<Map<String, dynamic>> _moduleList() {
      List<Map<String, dynamic>> _modules = [];

      // Add the relevant data from every unclosed module to the module list.
      Hive.box<Module>('modules').values.forEach((module) {
        if (!module.isClosed && module != omitModule) {
          _modules.add({
            'value': module.creationDate,
            'icon': Icon(Icons.stop, color: module.color),
            'label': module.name
          });
        }
      });

      // Change the data for the general module.
      _modules[0]['icon'] = Icon(Icons.stop, color: Color(0x00000000));
      _modules[0]['label'] = "Kein Modul";

      // If additional entries are given, they are added to the beginning
      // of the list.
      if (additionalEntries != null) {
        for (Map<String, dynamic> entry in additionalEntries!) {
          _modules.insert(0, entry);
        }
      }

      return _modules;
    }

    return Container(
      child: SelectFormField(
        // Removes the leading icon.
        decoration: InputDecoration(
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            semanticLabel: "Modul auswählen",
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          icon: null,
        ),

        type: SelectFormFieldType.dialog,
        initialValue: _currentModuleCreationDate,
        changeIcon: true,
        dialogTitle: 'Wähle ein Modul aus',
        dialogCancelBtn: 'ABBRECHEN',
        enableSearch: true,
        dialogSearchHint: 'Suche Modul',
        items: _moduleList(),
        onChanged: (String? moduleCreationDate) {
          _currentModuleCreationDate = moduleCreationDate!;
          Module? _currentModule =
              Hive.box<Module>('modules').get(_currentModuleCreationDate);
          _setModule(_currentModuleCreationDate);
          _setColor(
              _currentModule != null ? _currentModule.color : Colors.blueGrey);
        },
      ),
    );
  }
}
