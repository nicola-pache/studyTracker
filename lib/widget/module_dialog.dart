import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // includes TextInputFormatter
import '../widget/color_picker.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:hive/hive.dart';

/// Creates a module dialog.
class ModuleDialog extends StatelessWidget {
  ModuleDialog(
      {required this.context, required this.onSave, this.module, Key? key})
      : super(key: key);

  /// The context of the dialog.
  final BuildContext context;

  /// Function that will be executed on saving the module.
  final Function(Module) onSave;

  /// The module that will be created or changed.
  final Module? module;

  /// The HiveBox with the modules for easier reference.
  final Box<Module> _moduleBox = Hive.box<Module>('modules');

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return _showModuleDialog(onSave: this.onSave);
  }

  /// Shows a dialog to add a module or modify an existing module.
  /// Parameter index is optional.
  AlertDialog _showModuleDialog({required Function(Module) onSave}) {
    // Key to identify the state of the form and validate the inputs
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Module is created when it doesn't exist already
    Module module =
        this.module ?? Module(creationDate: DateTime.now().toUtc().toString());

    // Currently selected color of color picker
    Color _selectedColor = module.color;

    // Sets the currently selected color of color picker
    void _setColor(Color color) {
      _selectedColor = color;
    }

    // Creates a color picker, default color is the module's color
    SelectColor _colorPicker = SelectColor(module.color, _setColor);

    // Shows form in an alert dialog
    return AlertDialog(
        title: const Text('Modul hinzufügen'),
        content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    autofocus: false,
                    initialValue: module.abbreviation,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Kürzel'),
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (String? value) {
                      String? errorMsg;
                      if (value == null || value.isEmpty) {
                        errorMsg = 'Bitte geben Sie ein Kürzel an.';
                      } else if (_modulesContainAbbreviation(
                          value, module.creationDate)) {
                        errorMsg = 'Das Kürzel existiert bereits. Bitte'
                            ' geben Sie ein anderes Kürzel an.';
                      }
                      return errorMsg;
                    },
                    onSaved: (String? value) {
                      module.abbreviation = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: module.name,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Name'),
                    validator: (String? value) {
                      String? errorMsg;
                      if (value == null || value.isEmpty) {
                        errorMsg = 'Bitte geben Sie einen Namen an.';
                      } else if (_modulesContainName(
                          value, module.creationDate)) {
                        errorMsg = 'Der Name existiert bereits. Bitte'
                            ' geben Sie einen anderen Namen an.';
                      }
                      return errorMsg;
                    },
                    onSaved: (String? value) {
                      module.name = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: module.teacher,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Lehrperson'),
                    onSaved: (String? value) {
                      module.teacher = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: module.semester,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Fachsemester'),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onSaved: (String? value) {
                      module.semester = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: module.credits,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Credits'),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onSaved: (String? value) {
                      module.credits = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: module.notes,
                    style: const TextStyle(fontSize: 18),
                    decoration: _decorateTextField('Anmerkungen'),
                    onSaved: (String? value) {
                      module.notes = value!;
                    },
                  ),
                  _colorPicker
                ],
              ),
            )),
        actions: <Widget>[
          TextButton(
            child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
              _colorPicker = SelectColor(module.color, _setColor);
              _formKey.currentState!.reset();
            },
          ),
          TextButton(
              child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  module.color = _selectedColor;
                  onSave(module);
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                }
              })
        ]);
  }

  /// Checks, if an abbreviation already exists in the module box.
  bool _modulesContainAbbreviation(String abbreviation, String creationDate) {

    // Iterates over the modules in the box and gets the first module of which
    // the abbreviation equals the searched abbreviation; if not found, it's null
    String? _date = _moduleBox.keys.firstWhere(
            (date) => _moduleBox.get(date)!.abbreviation == abbreviation,
        orElse: () => null);

    // Compares the date of the module with the searched abbreviation, if found,
    // to the creationDate of the current module, to make sure the abbreviation
    // found is not the abbreviation of the current module itself
    return _date != null && _date != creationDate;
  }

  /// Checks if a name already exists in the module box.
  bool _modulesContainName(String name, String creationDate) {

    // Iterates over the modules in the box and gets the first module of which
    // the name equals the searched name; if not found, it's null
    String? _date = _moduleBox.keys.firstWhere(
            (date) => _moduleBox.get(date)!.name == name, orElse: () => null);

    // Compares the date of the module with the searched name, if found, to
    // the creationDate of the current module, to make sure the name found is
    // not the name of the current module itself
    return _date != null && _date != creationDate;
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