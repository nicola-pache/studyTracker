import 'package:flutter/material.dart';

// Import requires including the date_time_picker in the pubspec.yaml!
import 'package:date_time_picker/date_time_picker.dart';

/// SelectDateTime as a stateful widget, part 1.
/// Creates the state of the SelectDateTime.
///
/// The SelectDateTime requires a [_defaultDateTime] to access the current dateTime
/// and the function [_setDateTime] to set a new dateTime.
class SelectDateTime extends StatefulWidget {
  const SelectDateTime(this._defaultDateTime, this._setDateTime, {Key? key})
      : super(key: key);

  /// Current dateTime.
  final String _defaultDateTime;

  /// Sets a new dateTime.
  final Function _setDateTime;

  @override
  _SelectDateTimeState createState() => _SelectDateTimeState();
}

/// Handles the state of the SelectDateTime.
/// This widget shows a separate day and time picker.
/// The values of both pickers form this dateTime.
class _SelectDateTimeState extends State<SelectDateTime> {

  /// DateTime that gets picked in the end.
  late String _dateTime;

  /// Initialize the dateTime.
  @override
  void initState() {
    _dateTime = widget._defaultDateTime;
    super.initState();
  }

  /// Initialise controller for the textformfield.
  late final _dateTimeController = TextEditingController(text: _dateTime);

  /// Dispose the controller.
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _dateTimeController.dispose();
    super.dispose();
  }

  /// Deletes the current selected date and time.
  void _deleteDateTime() {
    setState(() {
      _dateTime = "";
      widget._setDateTime(_dateTime);
    });
    _dateTimeController.text = "";
  }

  /// Builds a separate day and time picker.
  @override
  Widget build(BuildContext context) {
    String _currentDateTime = _dateTime;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DateTimePicker(
            // Adjust calender to german layout.
            locale: Locale('de', ''),

            type: DateTimePickerType.dateTimeSeparate,
            dateMask: 'dd.MM.yyyy',
            controller: _dateTimeController,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            dateLabelText: 'Datum',
            timeLabelText: "Uhrzeit",

            onChanged: (val) {
              _dateTimeController.text = (val);
              setState(() => widget._setDateTime(val));
            },
            validator: (val) {
              return null;
            },
            onSaved: (String? value) {
              _currentDateTime = (value!);
              _dateTimeController.text = (value);

              setState(() => _dateTime = _currentDateTime);
              widget._setDateTime(value);
            },
          ),
          Row(
            children: [
              Text("Fälligkeitsdatum",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      height: 1.75)),
              Spacer(),
              IconButton(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.centerRight,
                icon: Icon(
                  Icons.cancel_presentation,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  semanticLabel: "Fälligkeitsdatum löschen",
                ),
                onPressed: () {
                  _deleteDateTime();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
