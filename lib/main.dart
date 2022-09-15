import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:untitled/model/adapters.dart';
import 'package:untitled/page/calendar.dart';
import 'onboarding.dart';
import 'page_navigation.dart';
import 'page/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled/model/goals_model.dart';
import 'package:untitled/model/modules_model.dart';


/// The main method of the app.
/// It initializes the database, prepares the app with relevant data from the
/// database, and runs the app.
void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter<Goal>(GoalAdapter());
  Hive.registerAdapter<Module>(ModuleAdapter());
  Hive.registerAdapter<Duration>(DurationAdapter());
  Hive.registerAdapter<Color>(ColorAdapter());
  Hive.registerAdapter<TimeOfDay>(TimeOfDayAdapter());
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Goal>('goalsTemplates');
  await Hive.openBox<Module>('modules');
  await Hive.openBox('timetableEvents');
  await Hive.openBox('timer');
  await Hive.openBox('settings');
  await Hive.openBox('statistics');

  /**Hive.box('statistics').clear();
  Hive.box<Goal>('goals').clear();
  Hive.box<Goal>('goalsTemplates').clear();
  Hive.box<Module>('modules').clear();
  Hive.box('timetableEvents').clear();
  Hive.box('timer').clear();
  Hive.box('settings').clear();**/

  // Initialize box for goals
  Map<String, Goal> goals = {/**
    "2021-10-01 08:00:00Z": Goal(
        name: 'Test 1',
        color: Colors.blueGrey,
        creationDate: "2021-10-01 08:00:00Z"),
    "2021-10-01 14:00:00Z": Goal(
        name: 'Test goal',
        color: Colors.pink,
        creationDate: "2021-10-01 14:00:00Z")
      ..deadline = DateTime(2021, 11, 27)
      ..module = "2021-10-01 14:00:00Z",
    "2021-10-02 14:00:00Z": Goal(
        name: 'Another test goal',
        color: Colors.indigo,
        creationDate: "2021-10-02 14:00:00Z"),
    "2021-10-02 08:00:00Z": Goal(
        name: 'Third test goal',
        color: Colors.amber,
        creationDate: "2021-10-02 08:00:00Z")
      ..deadline = DateTime(2021, 11, 24)
      ..isCompleted = true
      ..module = "2021-10-02 08:00:00Z"**/
  };
  if (Hive.box<Goal>('goals').isEmpty) {
    Hive.box<Goal>('goals').putAll(goals);
  }

  // Initialize box for modules
  if (Hive.box<Module>('modules').isEmpty) {
    Map<String, Module> modules = {
      "0": Module(
          name: 'Allgemein',
          abbreviation: 'Allgemein',
          color: Colors.blueGrey,
          creationDate: "0"),
      /**"2021-10-01 14:00:00Z": Module(
          abbreviation: 'Testing',
          name: 'Test',
          color: Colors.pink,
          creationDate: "2021-10-01 14:00:00Z"),
      "2021-10-02 08:00:00Z": Module(
          abbreviation: 'TST',
          name: 'Another test',
          color: Colors.indigo,
          creationDate: "2021-10-02 08:00:00Z")**/
    };
    // Add all goals to the respective modules
    Hive.box<Goal>('goals').values.forEach((goal) {
      modules[goal.module]!.goals.add(goal);
    });
    Hive.box<Module>('modules').putAll(modules);
  }


  // Initialize box for timer
  if (Hive.box('timer').isEmpty) {
    // The active timer has a list, of which the first element gives the
    // info whether the current timer refers to a goal or module
    // (0 = goal, 1 = module), and the second element of the list refers to the
    // creation date of the goal/module as a String
    Hive.box('timer').put('activeTimer', null);

    // CountdownTime is of type Duration
    Hive.box('timer').put('countdownTime', Duration(minutes: 25));

    // timer types: 0 = stopwatch, 1 = countdown, 2 = pomodoro
    Hive.box('timer').put('standardTimerType', 0);

    // PomodoroTime is of type Duration
    Hive.box('timer').put('pomodoroTime', Duration(minutes: 25));

    // Pomodoro break time is of type Duration
    Hive.box('timer').put('pomodoroBreakTime', Duration(minutes: 5));

    // IsPomodoro is of type boolean (false means the pomodoro timer is on break)
    Hive.box('timer').put('isPomodoro', true);

    // TimerStarted is of type DateTime
    Hive.box('timer').put('timerStarted', null);

    // TimePassed is of type Duration
    Hive.box('timer').put('timePassed', Duration.zero);

    // IsRunning is of type Boolean
    Hive.box('timer').put('isRunning', false);
  }

  // Initialize box for settings
  if (Hive.box('settings').isEmpty) {
    // themes: 0 = system, 1 = light, 2 = dark
    Hive.box('settings').put('theme', 0);
    Hive.box('settings').put('timetableStart', TimeOfDay(hour: 8, minute: 0));
    Hive.box('settings').put('timetableEnd', TimeOfDay(hour: 19, minute: 0));
    Hive.box('settings')
        .put('timetableEventLength', TimeOfDay(hour: 1, minute: 30));
    Hive.box('settings').put('modulesSortOrder', 'abbreviationDescending');
    Hive.box('settings').put('goalsSortOrder', 'creationDateDescending');
    Hive.box('settings').put('goalsFilter', 'all');
    Hive.box('settings').put('modulesFilter', 'all');
    Hive.box('settings').put('showInCalendarDefault', false);
    Hive.box('settings').put('hasSeenTutorial', false);
    Hive.box('settings').put('statisticInterval', 1.0);
    Hive.box('settings').put('currentlySelectedSemester', '');
  }

  // Initializes the calendar so the events in it can be modified before
  // the calendar is opened
  Hive.box<Goal>('goals').values.forEach((goal) {
    if (!goal.isCompleted && !goal.isArchived) {
      Calendar.addGoalToCalendar(goal);
    }
  });

  // Initializes the timetable
  Hive.box('timetableEvents').get(Hive.box('settings')
      .get('currentlySelectedSemester'))?.values.forEach((event) {
    if (event[6]) {
      // if event is supposed to be shown in the calendar
      FlutterWeekViewEvent _newEvent = FlutterWeekViewEvent(
          title: event[0],
          description: event[1],
          backgroundColor: event[2],
          textStyle: TextStyle(color: event[3]),
          start: event[4],
          end: event[5]);
      Calendar.addTimetableEventToCalendar(_newEvent);
    }
  });

  // Makes sure the app will not change its orientation when the device is
  // rotated, and runs the app
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(StudyTracker());
  });
}

/// Builds the app.
/// Contains the name of the app, defines locales (english and german), and
/// sets the theme of the app
class StudyTracker extends StatelessWidget {
  const StudyTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        builder: (BuildContext context, int value, _) {
          return MaterialApp(
            title: 'studyTracker',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''), // English, no country code
              Locale('de', ''), // Deutsch, no country code
            ],
            // color schemes for light and dark theme are taken from
            // ColorScheme.fromSwatch and have been modified
            theme: ThemeData(colorScheme: customColorScheme(false)),
            darkTheme: ThemeData(
                colorScheme: customColorScheme(true),
                // some widgets need their own dark theme, as they are not affected
                // by the dark color scheme
                tabBarTheme: TabBarTheme(
                    indicator: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.deepOrange, width: 3.0)))),
                radioTheme: RadioThemeData(
                    fillColor:
                        MaterialStateProperty.all<Color>(Colors.deepOrange),
                    overlayColor: MaterialStateProperty.all<Color>(
                        Colors.deepOrangeAccent)),
                checkboxTheme: CheckboxThemeData(
                  fillColor:
                      MaterialStateProperty.all<Color>(Colors.deepOrange),
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                ),
                chipTheme: ChipThemeData.fromDefaults(
                    brightness: Brightness.dark,
                    secondaryColor: Colors.deepOrange,
                    labelStyle: TextStyle())),
            themeMode: value == 0
                ? ThemeMode.system
                : value == 1
                    ? ThemeMode.light
                    : ThemeMode.dark,
            home: Hive.box('settings').get('hasSeenTutorial')
              ? const Navigation()
              : const Onboarding()
          );
        },
        valueListenable: Settings.currentTheme);
  }

  // Custom color scheme based on material color scheme
  ColorScheme customColorScheme(bool isDark) {
    return ColorScheme(
        primary: isDark ? Colors.deepOrange : Colors.blue,
        primaryVariant: isDark ? Colors.black : Colors.blue[700]!,
        secondary: isDark ? Colors.deepOrangeAccent[200]! : Colors.blue,
        secondaryVariant:
            isDark ? Colors.deepOrangeAccent[700]! : Colors.blue[700]!,
        surface: isDark ? Colors.grey[800]! : Colors.white,
        background: isDark ? Colors.grey[700]! : Colors.blue[200]!,
        error: Colors.red[700]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
        onBackground: Colors.white,
        onError: isDark ? Colors.black : Colors.white,
        brightness: isDark ? Brightness.dark : Brightness.light);
  }
}
