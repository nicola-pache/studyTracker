import 'package:flutter/material.dart';
import 'package:untitled/model/modules_model.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/page/timer.dart';
import 'package:hive/hive.dart';

/// Creates a button which gives access to the timer.
class TimerButton extends StatelessWidget {
  const TimerButton(this.context, this.timer, {Key? key, this.showName = false})
      : super(key: key);

  /// Context of the timerButton.
  final BuildContext context;

  /// Currently active timer.
  final List timer;

  /// Shows the name of the active timer.
  final bool showName;

  /// Builds the widget.
  @override
  Widget build(BuildContext context) {
    return _timerButton(context, timer);
  }

  /// Creates the timer button.
  Widget _timerButton(BuildContext context, List timer) {
    Box timerBox = Hive.box('timer');

    bool _timerMatchesActiveTimer() {
      bool _matches = false;
      if (timerBox.get('isRunning')) {
        _matches = timerBox.get('activeTimer')[0] == timer[0] &&
            timerBox.get('activeTimer')[1] == timer[1];
      }
      return _matches;
    }

    bool _isActiveTimer = !timerBox.get('isRunning')
        || _timerMatchesActiveTimer();

    Color _buttonColor =
        _isActiveTimer ? Theme.of(context).colorScheme.primary : Colors.grey;

    return TextButton.icon(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: _buttonColor)),
        ),
      ),
      onPressed: _isActiveTimer
          ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TimerTabs(timer: timer);
              }));
            }
          : null,
      icon: Icon(Icons.access_alarm, color: _buttonColor, semanticLabel: "Timer",),
      label: Text(
        showName
            ? timer[0] == 0
                ? Hive.box<Goal>('goals').get(timer[1])!.name
                : Hive.box<Module>('modules').get(timer[1])!.name
            : _timerMatchesActiveTimer()
                ? 'Läuft...'
                : timer[0] == 0
                    ? Hive.box<Goal>('goals').get(timer[1])!.getTimeLearned()
                    : Hive.box<Module>('modules')
                        .get(timer[1])!
                        .formatTimeLearned(),
        style: TextStyle(color: _buttonColor),
      ),
    );
  }
}
