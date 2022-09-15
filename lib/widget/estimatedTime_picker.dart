import 'package:flutter/material.dart';

// Import requires including duration_picker in the pubspec.yaml!
import 'package:duration_picker/duration_picker.dart';

/// SelectEstimatedTime as a stateful widget, part 1.
/// Creates the state of the SelectEstimatedTime.
///
/// The SelectEstimatedTime requires a [_defaultEstimatedTime] to access the current estimatedTime
/// and the function [_setEstimatedTime] to set a new estimatedTime.
class SelectEstimatedTime extends StatefulWidget {
  const SelectEstimatedTime(this._defaultEstimatedTime, this._setEstimatedTime,
      {Key? key})
      : super(key: key);

  /// Current estimatedTime.
  final Duration? _defaultEstimatedTime;

  /// Sets a new estimatedTime.
  final Function _setEstimatedTime;

  @override
  _SelectEstimatedTimeState createState() => _SelectEstimatedTimeState();
}

/// Handles the state of the SelectEstimatedTime.
/// This widget shows a time picker.
class _SelectEstimatedTimeState extends State<SelectEstimatedTime> {
  /// EstimatedTime that gets picked in the end.
  late Duration? _estimatedTime;

  /// Initialize the time.
  @override
  void initState() {
    _estimatedTime = widget._defaultEstimatedTime;
    super.initState();
  }

  /// Initialise controller for the textformfield.
  late final _estimatedTimeController = TextEditingController(
      text: _setEstimatedTimeControllerText(_estimatedTime));

  /// Dispose the controller.
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _estimatedTimeController.dispose();
    super.dispose();
  }

  /// Builds a time picker.
  /// The picker must be opened through a TextFormField.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
          controller: _estimatedTimeController,
          readOnly: true,
          onTap: () {
            _showTimePicker();
          },
          onChanged: (String? value) {
            _estimatedTimeController.text = value!;
            widget._setEstimatedTime(_estimatedTime);
          },
          decoration: InputDecoration(
            helperStyle: const TextStyle(fontSize: 18),
            helperText: "Zeitaufwand",
            suffixIcon: Container(
              width: 10,
              margin: EdgeInsets.all(0),
              child: TextButton(
                onPressed: () {
                  _showTimePicker();
                },
                child: Icon(Icons.arrow_drop_down,
                    semanticLabel: "Zeitaufwand auswählen",
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
              ),
            ),
          )),
    );
  }

  /// Shows a time picker.
  /// The user can change the current selected time or cancel all changes.
  _showTimePicker() {
    Duration _currentEstimatedTime =
        (_estimatedTime == null) ? Duration(minutes: 0) : _estimatedTime!;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// Template
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                contentPadding:
                    EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 0),
                title: const Text('Zeitaufwand auswählen'),
                content: Container(
                    width: double.minPositive,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Wählen Sie den geschätzten Zeitaufwand aus:",
                              style: TextStyle(fontSize: 18)),
                          Expanded(
                              child: DurationPicker(
                            duration: _currentEstimatedTime,
                            onChange: (val) {
                              setState(() => _currentEstimatedTime = val);
                            },
                            snapToMins: 5.0,
                          )),
                        ])),
                actions: <Widget>[
                  TextButton(
                      child: const Text('ABBRECHEN',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  TextButton(
                      child: const Text('SPEICHERN',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        setState(() => _estimatedTime = _currentEstimatedTime);
                        _estimatedTimeController.text =
                            (_setEstimatedTimeControllerText(_estimatedTime));
                        widget._setEstimatedTime(_estimatedTime);
                        Navigator.of(context).pop();
                      })
                ]);
          });
        });
  }

  /// Sets the estimatedTimeController.
  String _setEstimatedTimeControllerText(Duration? duration) {
    String durationText = (duration == null || duration.inMinutes == 0)
        ? "Keine Angabe"
        : "${duration.inHours.toString().padLeft(2, '0')} Std. ${duration.inMinutes.remainder(60).toString().padLeft(2, '0')} Min.";

    return durationText;
  }
}
