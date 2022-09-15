import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:hive/hive.dart';
import 'package:untitled/page/single_timetable_event.dart';
import 'package:untitled/page/timetable.dart';
import 'color_picker.dart';
import 'custom_time_picker.dart';

/// This dialog lets the user create a new timetable event.
class TimetableDialog extends StatelessWidget {
  TimetableDialog(
      {required this.parentContext,
        required this.onSave,
        this.eventData,
        Key? key})
      : super(key: key);

  /// Context of the dialog.
  final BuildContext parentContext;

  /// Function that will be executed on saving the event.
  final Function(FlutterWeekViewEvent, bool) onSave;

  /// List of all data of the event.
  final List? eventData;

  /// Checks if the selected day is valid.
  final ValueNotifier<bool> _dayIsValid = ValueNotifier<bool>(true);

  /// Checks if the selected time is valid.
  final ValueNotifier<bool> _timeIsValid = ValueNotifier<bool>(true);

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return _showModuleDialog();
  }

  /// Shows a dialog with a form to create the event.
  AlertDialog _showModuleDialog() {
    // Key to identify the state of the form and validate the inputs
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // The data for the new event
    String _eventTitle;
    Color _eventBackgroundColor;
    String _eventRoom;
    TimeOfDay _eventStartTime;
    TimeOfDay _eventEndTime;
    int _eventDay; // 1 = Monday, 2 = Tuesday, ...
    bool _showInCalendar;

    // Old start time to identify the event
    DateTime? _oldStart;

    // Get the data of an already existing event
    if (eventData != null) {
      _eventTitle = eventData![0];
      _eventRoom = eventData![1] == ''
          ? ''
          : eventData![1].split('\n')[1];
      _eventBackgroundColor = eventData![2];
      _eventDay = eventData![4].weekday;
      _eventStartTime = TimeOfDay(
          hour: eventData![4].hour, minute: eventData![4].minute);
      _eventEndTime = TimeOfDay(
          hour: eventData![5].hour, minute: eventData![5].minute);
      _showInCalendar = eventData![6];
      _oldStart = eventData![4];

      // if event is not given, set default values
    } else {
      // The data for the new event
      _eventTitle = '';
      _eventBackgroundColor = Colors.black;
      _eventRoom = '';
      _eventStartTime = Hive.box('settings').get('timetableStart');
      _eventEndTime =
          _calculateNewEndTime(_eventStartTime, _eventStartTime);
      _eventDay = 1;
      _showInCalendar = Hive.box('settings').get('showInCalendarDefault');
    }

    // Shows the dialog with the form
    return AlertDialog(
        title: const Text('Veranstaltung hinzufügen'),
        content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                          autofocus: false,
                          style: const TextStyle(fontSize: 18),
                          initialValue: _eventTitle,
                          decoration: _decorateTextField('Name'),
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(6)
                          ],
                          validator: (String? value) {
                            String? errorMsg;
                            if (value == null || value.isEmpty) {
                              errorMsg = 'Bitte geben Sie einen Namen an.';
                            }
                            return errorMsg;
                          },
                          onSaved: (String? value) {
                            _eventTitle = value!;
                          }),
                      TextFormField(
                          style: const TextStyle(fontSize: 18),
                          initialValue: _eventRoom,
                          decoration: _decorateTextField('Raum'),
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(9)
                          ],
                          onSaved: (String? value) {
                            if (value != null && value.isNotEmpty) {
                              _eventRoom = "Raum:\n" + value;
                            }
                          }),
                      SizedBox(height: 15),
                      _daySelector(
                          initialDay: _eventDay,
                          onChanged: (selectedDay) => _eventDay = selectedDay),
                      SizedBox(height: 15),
                      _timePickers(
                          weekday: _eventDay,
                          initialStartTime: _eventStartTime,
                          initialEndTime: _eventEndTime,
                          onChanged: (TimeOfDay start, TimeOfDay end) {
                            _eventStartTime = start;
                            _eventEndTime = end;
                          }),
                      ValueListenableBuilder(
                          valueListenable: _timeIsValid,
                          builder: (BuildContext context, bool valid, _) {
                            Widget _widget;
                            if (!valid) {
                              _widget = Text(
                                  "Bitte wählen Sie eine Endzeit später als die"
                                      " Startzeit.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red));
                            } else {
                              _widget = SizedBox.shrink();
                            }
                            return _widget;
                          }),
                      ValueListenableBuilder(
                          valueListenable: _dayIsValid,
                          builder: (BuildContext context, bool valid, _) {
                            Widget _widget;
                            if (!valid) {
                              _widget = Text(
                                  "Diese Zeit ist nicht möglich. "
                                      "Bitte wählen Sie eine andere Zeit / einen "
                                      "anderen Tag.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red));
                            } else {
                              _widget = SizedBox.shrink();
                            }
                            return _widget;
                          }),
                      SelectColor(_eventBackgroundColor,
                              (Color color) => _eventBackgroundColor = color),
                      StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return CheckboxListTile(
                              title: Text("Diese Veranstaltung im Kalender "
                                  "anzeigen.",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)
                                  )),
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: _showInCalendar,
                              onChanged: (value) {
                                setState(() {
                                  _showInCalendar = value!;
                                });
                              },
                            );
                          })
                    ]))),
        actions: <Widget>[
          TextButton(
              child: const Text('ABBRECHEN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(parentContext).pop();
              }),
          TextButton(
              child: const Text('SPEICHERN', style: TextStyle(fontSize: 18)),
              onPressed: () {
                _dayIsValid.value = _checkIfTimeIsFree(
                    _eventDay, _eventStartTime, _eventEndTime, _oldStart);
                _timeIsValid.value = _isEndTimeAfterStartTime(_eventStartTime,
                    _eventEndTime);
                if (_formKey.currentState!.validate() && _dayIsValid.value
                    && _timeIsValid.value) {
                  _formKey.currentState!.save();
                  FlutterWeekViewEvent _newEvent = FlutterWeekViewEvent(
                    title: _eventTitle,
                    description: _eventRoom,
                    start: DateTime(1, 0, 3 + _eventDay, // DateTime(1,0,3) is a sunday
                        _eventStartTime.hour,
                        _eventStartTime.minute),
                    end: DateTime(1, 0, 3 + _eventDay, // DateTime(1,0,3) is a sunday
                        _eventEndTime.hour,
                        _eventEndTime.minute),
                    backgroundColor: _eventBackgroundColor,
                    textStyle: TextStyle(
                        color: _selectTextColor(_eventBackgroundColor)
                    ),
                    onTap: () {
                      Navigator.push(parentContext,
                          MaterialPageRoute(builder: (context) {
                            return SingleTimetableEvent(
                                startTime: DateTime(1, 0, 3 + _eventDay, // DateTime(1,0,3) is a sunday
                                    _eventStartTime.hour,
                                    _eventStartTime.minute),
                                parentContext: parentContext);
                          }));
                    },
                  );
                  onSave(_newEvent, _showInCalendar);
                  Navigator.of(parentContext).pop();
                }
              })
        ]);
  }

  /// Adds the hint text to a textFormField.
  InputDecoration _decorateTextField(String name) {
    return (InputDecoration(
        helperStyle: const TextStyle(fontSize: 18),
        helperMaxLines: 2,
        helperText: name,
        errorMaxLines: 5));
  }

  /// Decides if the text color is black or white depending on the background
  /// color of the event.
  Color _selectTextColor(Color backgroundColor) {
    bool _isDark = ThemeData.estimateBrightnessForColor(backgroundColor)
        == Brightness.dark;
    return _isDark ? Colors.white : Colors.black;
  }

  /// Shows a row of buttons one of which can be selected to choose a weekday.
  Widget _daySelector(
      {required int initialDay, required Function(int) onChanged}) {
    ValueNotifier<int> _selectedDay = ValueNotifier<int>(initialDay);
    List<String> _days = ['Mo', 'Di', 'Mi', 'Do', 'Fr'];
    List<Widget> _choiceChips = [];
    if (_choiceChips.isEmpty) {
      for (int index = 0; index < _days.length; index++) {
        _choiceChips.addAll([
          ValueListenableBuilder(
              valueListenable: _selectedDay,
              builder: (BuildContext context, int value, _) {
                return ChoiceChip(
                    padding: const EdgeInsets.all(5.0),
                    label: Text(_days[index]),
                    selected: value == index + 1,
                    onSelected: (bool selected) {
                      _selectedDay.value = index + 1;
                      _dayIsValid.value = true;
                      onChanged(index + 1);
                    });
              }),
          const SizedBox(width: 5.0)
        ]);
      }
    }
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _choiceChips)
              ),
              Text("Wochentag",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(parentContext)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      height: 1.15))
            ]));
  }

  /// Buttons to let the user choose start and end times.
  Widget _timePickers(
      {required int weekday,
        required TimeOfDay initialStartTime,
        required TimeOfDay initialEndTime,
        required Function(TimeOfDay, TimeOfDay) onChanged}) {

    // minimum and maximum possible for selecting a time
    TimeOfDay _minTime = Hive.box('settings').get('timetableStart');
    TimeOfDay _maxTime = Hive.box('settings').get('timetableEnd');

    // currently selected times
    TimeOfDay _currentStartTime = initialStartTime;
    TimeOfDay _currentEndTime = initialEndTime;

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          _dayIsValid.value = true;
          return Expanded(
              flex: 0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTimePicker(
                        label: "Beginn",
                        labelLength: 65,
                        labelColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        title: "Beginn der Veranstaltung",
                        initialTime: _currentStartTime,
                        minimumTime: _minTime,
                        maximumTime: _maxTime,
                        onChange: (pickedStartTime) {
                          setState(() {
                            _currentStartTime = pickedStartTime;
                            _currentEndTime = _calculateNewEndTime(_currentStartTime,
                                _currentEndTime);
                            _dayIsValid.value = true;
                            _timeIsValid.value = true;
                          });
                          onChanged(_currentStartTime, _currentEndTime);
                        }),
                    CustomTimePicker(
                        label: "Ende",
                        labelLength: 65,
                        labelColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        title: "Ende der Veranstaltung",
                        initialTime: _currentEndTime,
                        minimumTime: _minTime,
                        maximumTime: _maxTime,
                        onChange: (pickedEndTime) {
                          setState(() {
                            _currentEndTime = pickedEndTime;
                            _dayIsValid.value = true;
                            _timeIsValid.value = true;
                          });
                          onChanged(_currentStartTime, _currentEndTime);
                        })
                  ])
          );
        });
  }

  /// Checks whether the given dateTime is not during an existing event.
  bool _checkIfTimeIsFree(
      int weekday, TimeOfDay start, TimeOfDay end, DateTime? oldStart) {
    DateTime startDate = DateTime(1, 0, 3 + weekday, start.hour, start.minute);
    DateTime endDate = DateTime(1, 0, 3 + weekday, end.hour, end.minute);
    int length = Timetable.timetableEvents.length;
    bool _timeIsFree = true;
    for (int index = 0; index < length && _timeIsFree; index++) {
      FlutterWeekViewEvent _event = Timetable.timetableEvents[index];
      _timeIsFree = (startDate.compareTo(_event.start) < 0 &&
          endDate.compareTo(_event.start) <= 0) ||
          (startDate.compareTo(_event.end) >= 0 &&
              endDate.compareTo(_event.end) > 0);

      // If an event with overlapping times has been found, make sure it is not
      // the changed event itself
      if (!_timeIsFree && oldStart != null) {
        _timeIsFree = oldStart.compareTo(_event.start) == 0;
      }
    }
    return _timeIsFree;
  }

  /// Checks if the end time is after the start time.
  bool _isEndTimeAfterStartTime(TimeOfDay start, TimeOfDay end) {
    bool _endTimeIsAfterStartTime = true;
    int _startMinutes = start.hour * 60 + start.minute;
    int _endMinutes = end.hour * 60 + end.minute;
    if (_endMinutes <= _startMinutes) {
      _endTimeIsAfterStartTime = false;
    }
    return _endTimeIsAfterStartTime;
  }

  // calculates the new end time after a minimum distance from the start time
  TimeOfDay _calculateNewEndTime(TimeOfDay start, TimeOfDay end) {
    TimeOfDay _newEndTime;
    TimeOfDay _eventLength = Hive.box('settings').get('timetableEventLength');
    int _lengthMinutes = _eventLength.hour * 60 + _eventLength.minute;
    int _endMinutes = end.hour * 60 + end.minute;
    int _startMinutes = start.hour * 60 + start.minute;
    if (_endMinutes - _startMinutes < _lengthMinutes) {
      int _newEndTimeMinutes = _startMinutes + _lengthMinutes;
      _newEndTime = TimeOfDay(hour: ((_newEndTimeMinutes) / 60).floor(),
          minute: (_newEndTimeMinutes) % 60);
    } else {
      _newEndTime = end;
    }
    return _newEndTime;
  }
}
