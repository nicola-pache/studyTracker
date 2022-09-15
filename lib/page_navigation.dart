import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled/page/profile.dart';
import 'package:untitled/page/startpage.dart';
import 'package:untitled/page/timer.dart';
import 'package:untitled/page/timetable.dart';
import 'package:untitled/widget/timer_button.dart';
import 'model/goals_model.dart';
import 'model/modules_model.dart';
import 'page/calendar.dart';
import 'page/goals.dart';
import 'page/tab_widget.dart';
import 'page/modules.dart';

import 'package:hive/hive.dart';
import 'package:untitled/page/statistics.dart';

/// Create NavigationBar as StatefulWidget, part 1.
class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  /// Controls the timer (de-)activation in goal- and module-lists
  /// as well as the floating action button.
  static ValueNotifier<bool> timerActivated = ValueNotifier<bool>(false);

  ///  Index of currently selected NavigationBarItem.
  static ValueNotifier<int> selectedNavBarIndex = ValueNotifier<int>(0);

  /// Creates PageController for PageView.
  static PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  _NavigationState createState() => _NavigationState();
}

/// Create NavigationBar as StatefulWidget, part 2.
class _NavigationState extends State<Navigation> {

  /// Timer to check whether the time of a currently active timer is up.
  Timer? timer;

  /// List of NavigationBarItems.
  static const List<BottomNavigationBarItem> navBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home, semanticLabel: "Startseite"),label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted, semanticLabel: "Übersichtsseite Ziele und Module"), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today, semanticLabel: "Kalender und Stundenplan-Seite"), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.show_chart, semanticLabel: "Statistikseite"), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.person, semanticLabel: "Profilseite"), label: '')
  ];

  /// List of all Pages in the App.
  static List<Widget> _createPages(BuildContext navigationContext) {
    return [
      const Startpage(),
      TabBarWidget(
          ['Ziele', 'Module'],
          [GoalsList(), ModulesList()]
      ),
      TabBarWidget(
          ['Kalender', 'Stundenplan'],
          [Calendar(navigationContext), Timetable(navigationContext)]
      ),
      Statistics(),
      const Profile()
    ];
  }

  /// Builds the pageView.
  Widget buildPageView(BuildContext navigationContext) {
    return PageView(
      controller: Navigation.pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: _createPages(navigationContext),
    );
  }

  /// Checks if the time of the currently active timer is up.
  void checkTimer() {
    Box _timerBox = Hive.box('timer');
    if (_timerBox.get('isRunning')
        && (_timerBox.get('standardTimerType') == 1
          || _timerBox.get('standardTimerType') == 2)) {
      Duration _countdownTime = _timerBox.get('standardTimerType') == 1
          ? _timerBox.get('countdownTime')
          : _timerBox.get('isPomodoro')
              ? _timerBox.get('pomodoroTime')
              : _timerBox.get('pomodoroBreakTime');
      DateTime _timerStarted = _timerBox.get('timerStarted');
      Duration _timePassed = _timerBox.get('timePassed') ?? Duration.zero;

      // Make sure any earlier timer has been canceled
      if (timer != null) {
        timer!.cancel();
      }

      // Every second the timer checks if the time ran out: if it's up,
      // the time learned is saved to the respective goal/module
      // and the data about the timer are being reset
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if ((DateTime.now().toUtc().difference(_timerStarted) + _timePassed) >
                (_countdownTime - Duration(milliseconds: 900)) &&
            _timerBox.get('activeTimer') != null) {
          timer!.cancel();
          // only save the time if the timer is not a pomodoro break
          if (_timerBox.get('isRunning')
              && !(_timerBox.get('standardTimerType') == 2
                  && !_timerBox.get('isPomodoro'))) {
            List _activeTimer = _timerBox.get('activeTimer');
            dynamic _moduleOrGoal = _activeTimer[0] == 0
                ? Hive.box<Goal>('goals').get(_activeTimer[1])
                : Hive.box<Module>('modules').get(_activeTimer[1]);
            _moduleOrGoal.timeLearned +=
                DateTime.now().toUtc().difference(_timerStarted);
            _moduleOrGoal.save();
            if (_moduleOrGoal is Goal) {
              Module module = Hive.box<Module>('modules').get(_moduleOrGoal.module)!;
              module.timeLearned += _timePassed;
              module.save();
            }
            TimerTabs.saveStatistics(_timePassed, _activeTimer);
          }
          // reset the timer
          _timerBox.put('activeTimer', null);
          _timerBox.put('isRunning', false);
          _timerBox.put('timerStarted', null);
          _timerBox.put('timePassed', Duration.zero);

          // if the pomodoro timer is selected, switch the pomodoro phase
          if (_timerBox.get('standardTimerType') == 2) {
            _timerBox.put('isPomodoro', !_timerBox.get('isPomodoro'));
          }
          Navigation.timerActivated.value = !Navigation.timerActivated.value;
        }
      });
      // If the timer exists but has been stopped it gets canceled
    } else {
      if (timer != null) {
        timer!.cancel();
      }
    }
  }

  /// Initializes the page navigation.
  @override
  void initState() {
    super.initState();
  }

  /// When the page navigation is disposed (usually when closing the app),
  /// Hive will be closed to in order to prevent memory loss.
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  /// Builds the app layout.
  ///
  /// It consists of a navigation bar at the bottom and,
  /// on top of the navigation bar, a persistent button which leads to the active
  /// timer if there is one.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: Navigation.timerActivated,
        builder: (context, value, _) {
          checkTimer();
          return ValueListenableBuilder<int>(
              valueListenable: Navigation.selectedNavBarIndex,
              builder: (context, value, _) {
                return Scaffold(
                  body: buildPageView(context),
                  persistentFooterButtons: Hive.box('timer').get('isRunning')
                      ? [
                          Center(
                              child: TimerButton(
                                  context, Hive.box('timer').get('activeTimer'),
                                  showName: true))
                        ]
                      : null,
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    iconSize: 40.0,
                    currentIndex: Navigation.selectedNavBarIndex.value,
                    onTap: (index) {
                      navBarTapped(index);
                    },
                    items: navBarItems,
                  ),
                );
              });
        });
  }

  /// If the page in PageView changes, the selected icon in the NavigationBar will
  /// change too.
  void pageChanged(int index) {
    setState(() => Navigation.selectedNavBarIndex.value = index);
  }

  /// If an icon in the NavigationBar is selected, the PageView will jump to
  /// the corresponding page.
  void navBarTapped(int index) {
    setState(() {
      Navigation.selectedNavBarIndex.value = index;
      Navigation.pageController.jumpToPage(index);
      //pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }
}
