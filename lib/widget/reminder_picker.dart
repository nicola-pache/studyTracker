import 'package:flutter/material.dart';
import 'package:untitled/widget/goal_dialog.dart';
import '../notification_services.dart';

/// Options of reminders to choose from.
enum ReminderTime {
  none,
  oneHourBefore,
  oneDayBefore,
  oneWeekBefore,
  individual,
  individualNew
}

/// SelectReminder as a stateful widget, part 1.
/// Creates the state of the SelectReminder.
///
/// The SelectReminder requires a [_defaultReminder] to access the current reminder
/// and the function [_setDateReinder] to set a new reminder.
class SelectReminder extends StatefulWidget {
  const SelectReminder(this._defaultReminder, this._setReminder, {Key? key})
      : super(key: key);

  /// Current reminder.
  final String? _defaultReminder;

  /// Sets a new reminder.
  final Function _setReminder;

  @override
  _SelectReminderState createState() => _SelectReminderState();
}

/// Handles the state of the SelectReminder.
/// This widget shows a reminder picker.
class _SelectReminderState extends State<SelectReminder> {
  /// Selected reminder when opening the reminder picker.
  late ReminderTime? _selectedReminderTime =
      (_reminder == null || _reminder == 'Keine Erinnerung')
          ? ReminderTime.none
          : (_reminder == "1 Stunde vorher")
              ? ReminderTime.oneHourBefore
              : (_reminder == "1 Tag vorher")
                  ? ReminderTime.oneDayBefore
                  : (_reminder == "1 Woche vorher")
                      ? ReminderTime.oneWeekBefore
                      : ReminderTime.individualNew;

  /// The reminder that will be picked in the end.
  late String? _reminder;

  /// Helper for reminder notifications.
  var notifyHelper;

  /// Initialize the reminder and notifications.
  @override
  void initState() {
    _reminder = widget._defaultReminder;
    notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    super.initState();
  }

  /// Initialise controller for textFormField.
  late final _reminderController =
      TextEditingController(text: _setReminderControllerText(_reminder));

  /// Set the reminderControllerText.
  String? _setReminderControllerText(String? text) {
    String? ReminderText = (text == null) ? "Keine Erinnerung" : text;
    return ReminderText;
  }

  /// Dispose the controller.
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _reminderController.dispose();
    super.dispose();
  }

  /// The reminder picker must be opened through a TextFormField.
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            TextFormField(
                controller: _reminderController,
                readOnly: true,
                onTap: () {
                  _showReminderPicker();
                },
                onChanged: (String? value) {
                  _reminderController.text = value!;
                  _reminder = value;
                  widget._setReminder(_reminder);
                },
                validator: (value) {
                  if (GoalDialog.validator.value == "Deadline Leer") {
                    return "Fälligkeitsdatum für die Erinnerung fehlt";
                  } else if (GoalDialog.validator.value ==
                      "Erinnerung nach Fälligkeitsdatum") {
                    return "Erinnerung ist nach dem Fälligkeitsdatum";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  helperStyle: const TextStyle(fontSize: 18),
                  helperText: "Erinnerung",
                  suffixIcon: Container(
                    width: 10,
                    margin: EdgeInsets.all(0),
                    child: TextButton(
                      onPressed: () {
                        _showReminderPicker();
                      },
                      child: Icon(Icons.arrow_drop_down,
                          semanticLabel: "Erinnerung auswählen",
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                  ),
                )),
          ],
        ));
  }

  /// Shows the reminder picker.
  /// The user can choose one of the displayed reminders,
  /// create an individual reminder or cancel the selection.
  _showReminderPicker() {
    // The reminder that is currently picked.
    String? _currentReminder = _reminder;
    String? _reminderBeforeIndividual = _reminder;

    // Shows a dialog with the reminder picker.
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// Template
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: const Text(
                    'Wählen Sie aus, wann Sie erinnert werden möchten'),
                content: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Keine Erinnerung'),
                      leading: Radio<ReminderTime>(
                        value: ReminderTime.none,
                        groupValue: _selectedReminderTime,
                        onChanged: (ReminderTime? value) {
                          setState(() {
                            _selectedReminderTime = value;
                            _currentReminder = 'Keine Erinnerung';
                            _reminderBeforeIndividual = 'Keine Erinnerung';
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('1 Stunde vorher'),
                      leading: Radio<ReminderTime>(
                        value: ReminderTime.oneHourBefore,
                        groupValue: _selectedReminderTime,
                        onChanged: (ReminderTime? value) {
                          setState(() {
                            _selectedReminderTime = value;
                            _currentReminder = '1 Stunde vorher';
                            _reminderBeforeIndividual = '1 Stunde vorher';
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('1 Tag vorher'),
                      leading: Radio<ReminderTime>(
                        value: ReminderTime.oneDayBefore,
                        groupValue: _selectedReminderTime,
                        onChanged: (ReminderTime? value) {
                          setState(() {
                            _selectedReminderTime = value;
                            _currentReminder = '1 Tag vorher';
                            _reminderBeforeIndividual = '1 Tag vorher';
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('1 Woche vorher'),
                      leading: Radio<ReminderTime>(
                        value: ReminderTime.oneWeekBefore,
                        groupValue: _selectedReminderTime,
                        onChanged: (ReminderTime? value) {
                          setState(() {
                            _selectedReminderTime = value;
                            _currentReminder = '1 Woche vorher';
                            _reminderBeforeIndividual = '1 Woche vorher';
                          });
                        },
                      ),
                    ),
                    Container(
                      child:
                          (_selectedReminderTime == ReminderTime.individual ||
                                  _selectedReminderTime ==
                                      ReminderTime.individualNew)
                              ? ListTile(
                                  title: Text(_reminderController.text),
                                  leading: Radio<ReminderTime>(
                                    value: (_selectedReminderTime ==
                                            ReminderTime.individual)
                                        ? ReminderTime.individual
                                        : ReminderTime.individualNew,
                                    groupValue: _selectedReminderTime,
                                    onChanged: (ReminderTime? value) {
                                      setState(() {
                                        _selectedReminderTime = value;
                                        _currentReminder = 'Individuell';
                                        _showIndividualPicker(
                                            _reminderBeforeIndividual);
                                      });
                                    },
                                  ),
                                )
                              : null,
                    ),
                    Container(
                      child: (_selectedReminderTime ==
                                  ReminderTime.individual ||
                              _selectedReminderTime ==
                                  ReminderTime.individualNew)
                          ? ListTile(
                              title: const Text('Individuell'),
                              leading: Radio<ReminderTime>(
                                value: (_selectedReminderTime ==
                                        ReminderTime.individualNew)
                                    ? ReminderTime.individual
                                    : ReminderTime.individualNew,
                                groupValue: _selectedReminderTime,
                                onChanged: (ReminderTime? value) {
                                  setState(() {
                                    _selectedReminderTime = value;
                                    _currentReminder = 'Individuell';
                                    _reminderBeforeIndividual = 'Individuell';
                                    _showIndividualPicker(
                                        _reminderBeforeIndividual);
                                  });
                                },
                              ),
                            )
                          : null,
                    ),
                    Container(
                      child:
                          (_selectedReminderTime != ReminderTime.individual &&
                                  _selectedReminderTime !=
                                      ReminderTime.individualNew)
                              ? ListTile(
                                  title: const Text('Individuell'),
                                  leading: Radio<ReminderTime>(
                                    value: ReminderTime.individual,
                                    groupValue: _selectedReminderTime,
                                    onChanged: (ReminderTime? value) {
                                      setState(() {
                                        _selectedReminderTime = value;
                                        _currentReminder = 'Individuell';
                                        _showIndividualPicker(
                                            _reminderBeforeIndividual);
                                      });
                                    },
                                  ),
                                )
                              : null,
                    ),
                  ],
                )),
                actions: <Widget>[
                  TextButton(
                    child:
                        const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      child: const Text('SPEICHERN',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        setState(() => _reminder = _currentReminder);
                        _reminderController.text = ((_currentReminder == null)
                            ? 'Keine Erinnerung'
                            : _currentReminder)!;
                        widget._setReminder(_currentReminder);

                        Navigator.of(context).pop();
                      })
                ]);
          });
        });
  }

  /// Current individual reminder.
  String _individualReminder = "";

  /// Shows the individual reminder picker, when selected.
  _showIndividualPicker(String? _reminderBeforeIndividual) {
    String _dropdownValue = "Minuten vorher";
    String _individualTime = "10";
    // Shows a dialog with the reminder picker
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// Template
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: const Text('Individuell'),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Container(
                          child: Row(children: [
                        Container(
                          width: 25,
                          margin: const EdgeInsets.all(8.0),
                          child: TextFormField(
                              initialValue: _individualTime,
                              //autofocus: true,
                              maxLength: 2,
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                counterText: "",
                              ),
                              onChanged: (String? value) {
                                _individualTime = value!;
                              },
                              onSaved: (String? value) {
                                _individualTime = value!;
                              },
                              keyboardType: TextInputType.number),
                        ),
                        Container(
                            width: 165,
                            margin: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: _dropdownValue,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6)),
                              focusColor: Theme.of(context).accentColor,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              underline: Container(
                                margin: EdgeInsets.all(0),
                                height: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                'Minuten vorher',
                                'Stunden vorher',
                                'Tage vorher',
                                'Wochen vorher'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ))
                      ]))
                    ])),
                actions: <Widget>[
                  TextButton(
                    child:
                        const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      _selectedReminderTime = (_reminderBeforeIndividual ==
                                  null ||
                              _reminderBeforeIndividual == 'Keine Erinnerung')
                          ? ReminderTime.none
                          : (_reminderBeforeIndividual == "1 Stunde vorher")
                              ? ReminderTime.oneHourBefore
                              : (_reminderBeforeIndividual == "1 Tag vorher")
                                  ? ReminderTime.oneDayBefore
                                  : (_reminderBeforeIndividual ==
                                          "1 Woche vorher")
                                      ? ReminderTime.oneWeekBefore
                                      : ReminderTime.individualNew;
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      _showReminderPicker();
                    },
                  ),
                  TextButton(
                      child: const Text('SPEICHERN',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        _individualReminder =
                            _individualTime + " " + _dropdownValue;
                        _reminderController.text = _individualReminder;

                        _selectedReminderTime = ReminderTime.individual;
                        setState(() => _reminder = _individualReminder);
                        widget._setReminder(_reminder);

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      })
                ]);
          });
        });
  }
}
