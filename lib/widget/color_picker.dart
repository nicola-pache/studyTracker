import 'package:flutter/material.dart';

// Import requires including the colorpicker-package in the pubspec.yaml!
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Creates a color picker, part 1.
class SelectColor extends StatefulWidget {
  const SelectColor(this._defaultColor,this._setColor,
      {Key? key}) : super(key: key);
  final Color _defaultColor;
  final Function _setColor;

  @override
  _SelectColorState createState() => _SelectColorState();
}

/// Creates a color picker, part 2.
class _SelectColorState extends State<SelectColor> {

  /// The color that will be picked in the end.
  late Color _color;

  /// Initializes the color.
  @override
  void initState() {
    _color = widget._defaultColor;
    super.initState();
  }

  /// The color picker must be opened with a button.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextButton.icon(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0.0)),
        ),
        icon: Icon(Icons.color_lens, size: 40, color: _color),
        label: const Text('Farbe auswählen',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.normal
            )
        ),
        onPressed: () {_showColorPicker();}
      )
    );
  }

  /// Creates the color picker.
  _showColorPicker() {

    // The color that is currently picked
    Color _currentColor = _color;

    // Shows a dialog with the color picker
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wählen Sie eine Farbe aus'),
          content: SingleChildScrollView(
              child: BlockPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (Color color) {
                    setState(() => _currentColor = color);
                  }
              )
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                setState(() => _color = _currentColor);
                widget._setColor(_currentColor);
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }
}