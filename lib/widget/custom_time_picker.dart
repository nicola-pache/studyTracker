import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates a custom time picker which has a minimum and maximum time.
class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker(
      {required this.label,
      this.labelLength,
      this.labelColor,
      required this.title,
      this.description,
      required this.initialTime,
      required this.onChange,
      this.minimumTime,
      this.maximumTime,
      this.validator,
      this.invalidMessage,
      Key? key})
      : super(key: key);

  /// The label of the time picker.
  final String label;

  /// The title that is shown in the dialog.
  final String title;

  /// The length of the label.
  final double? labelLength;

  /// The color of the label.
  final Color? labelColor;

  /// The text in the time picker dialog.
  final String? description;

  /// The initial time of the time picker.
  final TimeOfDay initialTime;

  /// Function that says what should happen on saving the time.
  final Function(TimeOfDay) onChange;

  /// The minimum time of the time picker.
  final TimeOfDay? minimumTime;

  /// The maximum time of the time picker.
  final TimeOfDay? maximumTime;

  /// Validates the selected time.
  final Function(dynamic)? validator;

  /// The message that shows up if the time is invalid.
  final String? invalidMessage;

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

/// Handles the state of the CustomTimePicker.
class _CustomTimePickerState extends State<CustomTimePicker> {

  /// The currently selected time.
  late TimeOfDay _selectedTime;

  /// Builds the custom time picker.
  @override
  Widget build(BuildContext context) {
    _selectedTime = widget.initialTime;
    return Row(
        children: <Widget> [
          Container(
            width: widget.labelLength,
            child: Text(widget.label,
                style: TextStyle(
                    fontSize: 18,
                    color: widget.labelColor ?? Theme.of(context)
                        .colorScheme
                        .onSurface,
                    height: 1.25))),
          TextButton.icon(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary)))),
              icon: Icon(Icons.access_time),
              label: Text(MaterialLocalizations.of(context)
                  .formatTimeOfDay(_selectedTime, alwaysUse24HourFormat: true),
                  style: TextStyle(fontSize: 15)),
              onPressed: () async {
                TimeOfDay? _newTime = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                  _showCustomTimePicker(context: context));
                setState(() {
                  if (_newTime != null) {
                    _selectedTime = _newTime;
                  }
                });
                widget.onChange(_selectedTime);
              })]);
  }

  /// Shows a dialog with a custom time picker.
  Widget _showCustomTimePicker({required BuildContext context}) {
    TimeOfDay _pickedTime = _selectedTime;
    String? _errorMessage;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 0),
          title: Text(widget.title),
          content: Container(
              width: double.minPositive,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.description != null)
                      Text(widget.description!, style: TextStyle(fontSize: 18)),
                    Container(
                        height: 250,
                        child: CupertinoTheme(
                            data: CupertinoThemeData(
                                brightness:
                                    Theme.of(context).colorScheme.brightness,
                                primaryColor:
                                    Theme.of(context).colorScheme.primary),
                            child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: DateTime(1, 0, 4,
                                    _pickedTime.hour, _pickedTime.minute),
                                minimumDate:
                                    _convertToDateTime(widget.minimumTime),
                                maximumDate:
                                    _convertToDateTime(widget.maximumTime),
                                use24hFormat: true,
                                onDateTimeChanged: (DateTime setTime) {
                                  _pickedTime = TimeOfDay(hour: setTime.hour,
                                      minute: setTime.minute);
                                }))),
                    if (_errorMessage != null)
                      Text(_errorMessage!,
                          style: TextStyle(fontSize: 18, color: Colors.red))
                  ])),
          actions: <Widget>[
            TextButton(
                child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  // check if the picked time already exists:
                  // an event with an existing sta
                  if (widget.validator != null &&
                      widget.validator!(_pickedTime)) {
                    setState(() => _errorMessage = widget.invalidMessage);
                  } else {
                    Navigator.pop(
                        context,
                        TimeOfDay(
                            hour: _pickedTime.hour,
                            minute: _pickedTime.minute));
                  }
                })
          ]);
    });
  }

  /// Converts the TimeOfDay given by the time picker to a DateTime.
  DateTime? _convertToDateTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      return DateTime(1, 0, 4, timeOfDay.hour, timeOfDay.minute);
    }
  }
}
