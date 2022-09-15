import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/model/modules_model.dart';
import 'dart:core';
import 'dart:async';
import '../notification_services.dart';
import '../page_navigation.dart';
import 'package:hive/hive.dart';

/// The box for the timer for easier reference.
Box _timerBox = Hive.box('timer');

/// The box recording data for the statistics.
Box statisticsBox = Hive.box('statistics');

/// The tabs for the timers as a stateful widget, part 1.
class TimerTabs extends StatefulWidget {
  const TimerTabs({required this.timer, Key? key}) : super(key: key);

  /// The currently active timer.
  final List timer;

  @override
  _TimerTabsState createState() => _TimerTabsState();

  /// Gives date current day, cuts time off.
  static String giveDate() {
    DateTime _now = DateTime.now();
    return DateTime.utc(_now.year, _now.month, _now.day).toString();
  }

  /// Saves timeLearned linked with the date of the recorded time
  /// to later be used in the statistics.
  static void saveStatistics(Duration timePassed, List timer) {
    String today = giveDate();
    String module = timer[0] == 0
        ? Hive.box<Goal>('goals').get(timer[1])!.module
        : Hive.box<Module>('modules').get(timer[1])!.creationDate;
    Map<String, Duration> _moduleTimeMap = Map<String, Duration>();
    if (statisticsBox.containsKey(today)) {
      _moduleTimeMap = Map.from(statisticsBox.get(today));
      if (_moduleTimeMap.containsKey(module)) {
        _moduleTimeMap[module] = _moduleTimeMap[module]! + timePassed;
      } else {
        _moduleTimeMap[module] = timePassed;
      }
    } else {
      _moduleTimeMap = {module: timePassed};
    }
    statisticsBox.put(today, _moduleTimeMap);
  }

  /// Deletes a module form the statistics chart.
  static void deleteModuleFromStatistics(String module) {
    for (String date in statisticsBox.keys) {
      Map map = statisticsBox.get(date);
      if (map.containsKey(module)) {
        map.remove(module);
        if (map.isEmpty) {
          statisticsBox.delete(date);
        }
      }
    }
  }
}

/// The tabs for the timers as a stateful widget, part 2.
class _TimerTabsState extends State<TimerTabs>
    with SingleTickerProviderStateMixin {

  /// The font size for the text.
  final TextStyle _textStyle = TextStyle(fontSize: 18);

  /// The tab controller that allows the tabs to be switch programmatically.
  late TabController _tabController;

  /// Initializes the widget.
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        initialIndex: _timerBox.get('standardTimerType'),
        vsync: this);
    _tabController.addListener(() {
      setState(() {
        _timerBox.put('standardTimerType', _tabController.index);
        _saveAndResetTimer();
      });
    });
  }

  /// Disposes the tabController, if it is not needed anymore.
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Buils the widget.
  @override
  Widget build(BuildContext context) {
    dynamic _moduleOrGoal = widget.timer[0] == 0
        ? Hive.box<Goal>('goals').get(widget.timer[1])
        : Hive.box<Module>('modules').get(widget.timer[1]);
    return Scaffold(
      appBar: AppBar(
        title: Text(_moduleOrGoal.name),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: _textStyle,
          unselectedLabelStyle: _textStyle,
          tabs: [
            Tab(text: "Stoppuhr"),
            Tab(text: "Countdown"),
            Tab(text: "Pomodoro"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StopwatchWidget(timer: widget.timer),
          CountdownWidget(timer: widget.timer, type: "Countdown"),
          CountdownWidget(timer: widget.timer, type: "Pomodoro"),
        ],
      ),
    );
  }

  /// Saves the time and resets the timer.
  void _saveAndResetTimer() {
    // Adds the time since the timer has been disposed to the
    // active goal/module, before the active timer is reset
    // (unless the timer was in pomodoro break mode)
    if (Hive.box('timer').get('isRunning') &&
        !(Hive.box('timer').get('standardTimerType') == 2 &&
            !Hive.box('timer').get('isPomodoro'))) {
      String _creationDate = Hive.box('timer').get('activeTimer')[1];
      dynamic _currentTimerObject = Hive.box('timer').get('activeTimer')[0] == 0
          ? Hive.box<Goal>('goals').get(_creationDate)!
          : Hive.box<Module>('modules').get(_creationDate)!;
      Duration _timePassed = DateTime.now()
          .toUtc()
          .difference(Hive.box('timer').get('timerStarted'));
      _currentTimerObject.timeLearned += _timePassed;
      _currentTimerObject.save();
    }

    // Resets the active timer
    Hive.box('timer').put('timerStarted', null);
    Hive.box('timer').put('activeTimer', null);
    Hive.box('timer').put('timePassed', Duration.zero);
    Hive.box('timer').put('isRunning', false);

    // Turns off the general link to the timer button
    Navigation.timerActivated.value = !Navigation.timerActivated.value;
  }
}

/// The timer as a stopwatch, part 1.
class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({required this.timer, Key? key}) : super(key: key);

  /// The currently active timer.
  final List timer;

  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

/// The timer as a stopwatch, part 2.
class _StopwatchWidgetState extends State<StopwatchWidget> {

  /// Counts the time.
  Timer _timer = Timer(Duration.zero, () {});

  /// The time when the timer has been started.
  late DateTime _timerStarted;

  /// The module or goal the timer belongs to.
  late dynamic _moduleOrGoal;

  /// The time that will be saved in the end.
  late Duration _timeLearned;

  /// The time that has passed.
  Duration _timePassed = Duration.zero;

  /// Whether the timer is currently running.
  bool _isRunning = false;

  /// Counts up the time passed since the timer has been started.
  void _countUp() {
    setState(
        () => _timePassed = DateTime.now().toUtc().difference(_timerStarted));
  }

  /// Starts the timer and initializes variables which haven't been initialized
  /// before (when the timer is started for the first time).
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _countUp());
    if (!_timerBox.get('isRunning')) {
      _timerStarted = DateTime.now().toUtc();
      _timerBox.put('timerStarted', _timerStarted);
      _timerBox.put('activeTimer', widget.timer);
    }
    _timerBox.put('isRunning', true);

    // Helper for timer notifications
    var notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

    notifyHelper.scheduledNotification(
        220203,
        DateTime.now().add(Duration(hours: 2)),
        Duration(),
        "Timer aktiv",
        "Hallo, bist du noch da? Dein Timer ist noch aktiv!",
        'payload',
        context);

    Navigation.timerActivated.value = !Navigation.timerActivated.value;
    setState(() => _isRunning = true);
  }

  /// Stops the timer, resets all the values and saves the time learned.
  void _stopTimer() {
    _timer.cancel();
    _moduleOrGoal.timeLearned += _timePassed;
    _moduleOrGoal.save();
    if (_moduleOrGoal is Goal) {
      Module module = Hive.box<Module>('modules').get(_moduleOrGoal.module)!;
      module.timeLearned += _timePassed;
      module.save();
    }
    TimerTabs.saveStatistics(_timePassed, widget.timer);
    _timerBox.put('timerStarted', null);
    _timerBox.put('activeTimer', null);
    _timerBox.put('isRunning', false);
    Navigation.timerActivated.value = !Navigation.timerActivated.value;
    setState(() {
      _timeLearned += _timePassed;
      _timerStarted = DateTime(0);
      _timePassed = Duration.zero;
      _isRunning = false;
    });

    // Helper for timer notifications
    var notifyHelper = NotifyHelper(context: context);
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

    notifyHelper.deleteNotification(220203);
  }

  /// Initializes the timer with all relevant data.
  @override
  void initState() {
    super.initState();
    _moduleOrGoal = widget.timer[0] == 0
        ? Hive.box<Goal>('goals').get(widget.timer[1])
        : Hive.box<Module>('modules').get(widget.timer[1]);
    _timeLearned = _moduleOrGoal.timeLearned;
    if (_timerBox.get('isRunning')) {
      _timerStarted = _timerBox.get('timerStarted');
      _timePassed = DateTime.now().toUtc().difference(_timerStarted);
      Future.delayed(Duration.zero, () async => _startTimer());
    }
  }

  /// The timer is cancelled when it is closed to avoid error messages.
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  /// Builds the page for the stopwatch timer.
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                  (_timeLearned + _timePassed)
                      .toString()
                      .split('.')
                      .first
                      .padLeft(8, "0"),
                  style: TextStyle(
                      fontSize: 50,
                      color: Theme.of(context).colorScheme.primary)),
              TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 15.0)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.surface),
                  ),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? "Stopp" : "Start",
                      style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    _isRunning ? _stopTimer() : _startTimer();
                  })
            ]));
  }
}

/// The timer as a countdown, part 1.
class CountdownWidget extends StatefulWidget {
  CountdownWidget({required this.timer, required this.type, Key? key})
      : super(key: key);

  /// The currently active timer.
  final List timer;

  /// The type of the timer (countdown or pomodoro).
  final String type;

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

/// The timer as a countdown, part 2.
class _CountdownWidgetState extends State<CountdownWidget> {

  /// The length of the countdown.
  late Duration _countdown;

  /// The time that has passed.
  late Duration _timePassed;

  /// Additional time for the countdown (fixes problems with rounding)
  late Duration _additionalTime = Duration.zero;

  /// Saves the current time after stopping.
  Timer? _timer = Timer(Duration.zero, () {});

  /// Time when timer has been started.
  DateTime? _timerStarted;

  /// The module or goal the timer belongs to.
  late dynamic _moduleOrGoal;

  /// Whether the timer is currently running.
  bool _isRunning = false;

  /// Counts down the time while the time is not up.
  void _countDown() {
    if (_timePassed < _countdown - Duration(seconds: 1)) {
      setState(() => _timePassed =
          DateTime.now().toUtc().difference(_timerStarted!) + _additionalTime);
    } else {
      setState(() {
        if (_timer != null) {
          _timer!.cancel();
        }
        _isRunning = false;
      });
    }
  }

  /// Starts the timer and initializes it further, if it has not been running
  /// before.
  void _startTimer() {
    if ((_countdown - _timePassed) < Duration(seconds: 1)) {
      _resetTimer();
    }
    if (!_timerBox.get('isRunning')) {
      _timerStarted = DateTime.now().toUtc();
      _timerBox.put('timerStarted', _timerStarted);
      _timerBox.put('activeTimer', widget.timer);
      _timerBox.put('isRunning', true);
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _countDown());
    Navigation.timerActivated.value = !Navigation.timerActivated.value;
    setState(() => _isRunning = true);
  }

  /// Stops the timer and saves the relevant data to the HiveBox.
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    if (!(widget.type.toLowerCase() == 'pomodoro' &&
        !_timerBox.get('isPomodoro'))) {
      _moduleOrGoal.timeLearned += _timePassed - _additionalTime;
      _moduleOrGoal.save();
      if (_moduleOrGoal is Goal) {
        Module module = Hive.box<Module>('modules').get(_moduleOrGoal.module)!;
        module.timeLearned += _timePassed;
        module.save();
      }
    }
    TimerTabs.saveStatistics(_timePassed, widget.timer);
    _timerBox.put('isRunning', false);
    _timerBox.put('timePassed', _timePassed);
    Navigation.timerActivated.value = !Navigation.timerActivated.value;
    setState(() {
      _isRunning = false;
      _additionalTime = _timePassed;
    });
  }

  /// Resets the timer to its default values.
  void _resetTimer() {
    _timerBox.put('timerStarted', null);
    _timerBox.put('activeTimer', null);
    _timerBox.put('timePassed', Duration.zero);
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      if (widget.type.toLowerCase() == 'pomodoro') {
        _countdown = Duration(
            seconds: _timerBox
                .get(_timerBox.get('isPomodoro')
                    ? 'pomodoroTime'
                    : 'pomodoroBreakTime')
                .inSeconds,
            milliseconds: 900);
      }
      _timer = null;
      _timerStarted = null;
      _timePassed = Duration.zero;
      _additionalTime = Duration.zero;
    });
  }

  /// Initializes the countdown timer.
  @override
  void initState() {
    super.initState();

    // The current module or goal is needed to save the learned time to it
    _moduleOrGoal = widget.timer[0] == 0
        ? Hive.box<Goal>('goals').get(widget.timer[1])
        : Hive.box<Module>('modules').get(widget.timer[1]);

    // Rounds down the countdown to avoid rounding issues later
    if (widget.type.toLowerCase() == 'countdown') {
      _countdown = Duration(
          seconds: _timerBox.get('countdownTime').inSeconds, milliseconds: 900);
    } else if (widget.type.toLowerCase() == 'pomodoro') {
      _countdown = Duration(
          seconds: _timerBox
              .get(_timerBox.get('isPomodoro')
                  ? 'pomodoroTime'
                  : 'pomodoroBreakTime')
              .inSeconds,
          milliseconds: 900);
    }

    // If the timer is running, the timer is initialized with data as if it had
    // been running all along
    if (_timerBox.get('isRunning')) {
      _timerStarted = _timerBox.get('timerStarted');
      _additionalTime = _timerBox.get('timePassed');
      _timePassed =
          DateTime.now().toUtc().difference(_timerStarted!) + _additionalTime;
      Future.delayed(Duration.zero, () async => _startTimer());
    } else {
      // If the timer was not running but is the active timer, it is initialized
      // with the data from the last stop
      List? _activeTimer = _timerBox.get('activeTimer');
      if (_activeTimer != null &&
          _activeTimer[0] == widget.timer[0] &&
          _activeTimer[1] == widget.timer[1]) {
        _timerStarted =
            _timerBox.get('timerStarted').add(_timerBox.get('timePassed'));
        _timePassed = _timerBox.get('timePassed');
        _additionalTime = _timerBox.get('timePassed');
      } else {
        // If the timer was neither running nor is it the active timer,
        // the passed time is set to zero; all further relevant data
        // will be initialized on starting the timer
        _timePassed = Duration.zero;
        _timerBox.put('timePassed', _timePassed);
      }
    }
  }

  /// The timer is cancelled when it is closed to avoid errors.
  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  /// Builds the page for the countdown timer.
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.type.toLowerCase() == 'pomodoro')
                Text(_timerBox.get('isPomodoro') ? "Pomodoro" : "Pause",
                    style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primary)),
              SizedBox(height: 15),
              Text(
                  (_countdown - _timePassed)
                      .toString()
                      .split('.')
                      .first
                      .padLeft(8, "0"),
                  style: TextStyle(
                      fontSize: 50,
                      color: (_countdown - _timePassed) < Duration(seconds: 1)
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary)),
              SizedBox(height: 15),
              TextButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 15.0)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.surface),
                  ),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? "Stopp" : "Start",
                      style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    _isRunning ? _stopTimer() : _startTimer();
                  }),
              if (!_isRunning)
                _buildTextButton(
                    title: "Zeit ändern",
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _showTimePicker();
                          });
                    }),
              if (!_isRunning && widget.type.toLowerCase() == 'pomodoro')
                _buildTextButton(
                    title: _timerBox.get('isPomodoro')
                        ? "Zu Pause wechseln"
                        : "Zu Pomodoro wechseln",
                    onPressed: () => _switchBetweenPomodoroAndBreak()),
              if (!_isRunning)
                _buildTextButton(
                    title: "Zeit zurücksetzen", onPressed: () => _resetTimer())
            ]));
  }

  /// Builds a TextButton.
  TextButton _buildTextButton(
      {required String title, required Function() onPressed}) {
    return TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 15.0)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          ),
        ),
        child: Text(title,
            style: TextStyle(
                fontSize: 18.0, color: Theme.of(context).colorScheme.surface)),
        onPressed: onPressed);
  }

  /// Shows the TimePicker to change the time.
  AlertDialog _showTimePicker() {
    String _boxTime = widget.type.toLowerCase() == 'countdown'
        ? 'countdownTime'
        : _timerBox.get('isPomodoro')
            ? 'pomodoroTime'
            : 'pomodoroBreakTime';
    Duration _pickedTime = _timerBox.get(_boxTime);
    return AlertDialog(
        contentPadding:
            EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 0),
        title: const Text('Startzeit auswählen'),
        content: Container(
            width: double.minPositive,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Wählen Sie eine Startzeit aus:",
                      style: TextStyle(fontSize: 18)),
                  CupertinoTheme(
                      data: CupertinoThemeData(
                          brightness: Theme.of(context).colorScheme.brightness,
                          primaryColor: Theme.of(context).colorScheme.primary),
                      child: CupertinoTimerPicker(
                          initialTimerDuration: _pickedTime,
                          onTimerDurationChanged: (Duration setTime) {
                            _pickedTime = setTime;
                          }))
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
                _timerBox.put(_boxTime, _pickedTime);
                _countdown =
                    Duration(seconds: _pickedTime.inSeconds, milliseconds: 900);
                _resetTimer();
                Navigator.of(context).pop();
              })
        ]);
  }

  /// Switches between Pomodoro and Break phases.
  void _switchBetweenPomodoroAndBreak() {
    _stopTimer();
    bool _isCurrentlyPomodoro = _timerBox.get('isPomodoro');
    _timerBox.put('isPomodoro', !_isCurrentlyPomodoro);
    _resetTimer();
  }
}
