import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:untitled/page_navigation.dart';

/// Creates the onboarding tutorial.
class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  /// Ends the tutorial.
  void _onDonePress(BuildContext context) {
    // if the tutorial has been seen, it means that it has been opened from the
    // settings menu; in this case it can be simply closed again
    if (Hive.box('settings').get('hasSeenTutorial')) {
      Navigator.of(context).pop();

      // If the tutorial is seen for the first time, the variable for has been
      // seen is set to true and the tutorial replaced by the actual app
    } else {
      Hive.box('settings').put('hasSeenTutorial', true);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Navigation()));
    }
  }

  /// Creates the slide for an individual step of the tutorial.
  Slide _slide(
      {required BuildContext context,
        required String title,
        required String description,
        required String image,
        required String altText,
        bool appendTheme = true}) {

    // The color scheme of the current context
    ColorScheme _colorScheme = Theme.of(context).colorScheme;

    // Extension of the image file depends on if and which theme should be added
    String _extension = appendTheme
        ? _colorScheme.brightness == Brightness.light
            ? '_light.png'
            : '_dark.png'
        : '.png';

    // Path to the image based on the name of it and the extension
    String _imagePath = 'assets/$image$_extension';

    // The image is 3/4 of the screen size by default
    double _imageHeight = MediaQuery.of(context).size.height / 1.75;

    // Slide with the given arguments and more specifications which are the
    // same for all slides
    return Slide(
        title: title,
        marginTitle: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        styleTitle: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: _colorScheme.onSurface),
        description: description,
        styleDescription: TextStyle(
            fontSize: 18.0, color: _colorScheme.onSurface),
        marginDescription:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        centerWidget: InteractiveViewer( // the image can be enlarged
            panEnabled: false,
            minScale: 1,
            maxScale: 4,
            child: Image.asset(
                _imagePath,
                height: _imageHeight,
                semanticLabel: altText)
        ),
        backgroundColor: _colorScheme.surface);
  }

  /// Builds the tutorial.
  @override
  Widget build(BuildContext context) {
    // List of tutorial slides
    final List<Slide> _slides = [
      _slide(
          context: context,
          title: "Wilkommen",
          description: "Herzlich Willkommen bei studyTracker. Die nächsten "
              "Bilder geben dir eine kurze Einführung in die App. Wenn du das "
              "Tutorial beendest oder übersprungen hast, kannst du es dir "
              "jederzeit in den Einstellungen nochmal starten.",
          image: 'logo',
          appendTheme: false,
          altText: "Ein Bild, das die Startseite zeigt."),
      _slide(
          context: context,
          title: "Startseite",
          description: "Auf der Startseite werden dir die nächsten 5 Ziele "
              "sowie die Veranstaltungen für heute angezeigt.",
          image: 'startpage',
          altText: "Ein Bild, das die Startseite zeigt."),
      _slide(
          context: context,
          title: "Ziele",
          description: "Auf der Zielseite kannst du neue Ziele erstellen und "
              "auf die einzelnen Ziele zugreifen. Außerdem kannst du die "
              "Ziele sortieren und filtern.",
          image: 'goalsSettings',
          altText: "Bilder, die die Ziele und dazugehörige Einstellungen zeigen."),
      _slide(
          context: context,
          title: "Neues Ziel hinzufügen",
          description: "Wenn du ein neues Ziel hinzufügst, musst du nur das "
              "Feld für den Namen ausfüllen, alles andere ist optional.",
          image: 'addGoal',
          altText: "Ein Bild, das das Formular zum Erstellen eines neuen Ziels"
              "zeigt."),
      _slide(
          context: context,
          title: "Ziel im Detail",
          description: "Klicken auf ein Ziel führt dich zur Detailansicht, die "
              "u.a. zeigt, wieviel du schon im Vergleich zu deinem angegebenen "
              "Aufwand gelernt hast.",
          image: 'singleGoal',
          altText: "Ein Bild, das die Detailansicht eines Ziels zeigt."),
      _slide(
          context: context,
          title: "Vorlagen und Erinnerungen",
          description: "In den Einstellungen der Ziele findest du außerdem eine "
              "Vorlagenverwaltung und einen Erinnerungsmanager.",
          image: 'templatesReminders',
          altText: "Ein Bild, das die Vorlagen und Erinnerungen für Ziele zeigt."),
      _slide(
          context: context,
          title: "Module",
          description: "Die Modulseite ist analog zur Zielseite: du kannst also "
              "deine Module verwalten, sortieren und filtern.",
          image: 'modulesAddModule',
          altText: "Ein Bild, das die Übersicht der Module zeigt."),
      _slide(
          context: context,
          title: "Timer",
          description: "Du kannst deine Lernzeit messen mit einer einfachen "
              "Stoppuhr, einem Countdown, oder einem Pomodoro-Timer. Der "
              "Pomodoro-Timer wechselt zwischen einer Pomodoro-Phase (Zeit zum "
              "Lernen) und einer Pause-Phase.",
          image: 'timer',
          altText: "Bilder, die die verschiedenen Timer zeigen."),
      _slide(
          context: context,
          title: "Kalender",
          description: "Im Kalender siehst du eine Übersicht über die Deadlines "
              "deiner Ziele. Der Kalender dient nur zur Übersicht, du kannst "
              "keine separaten Termine eintragen.",
          image: 'calendar',
          altText: "Ein Bild, das den Kalender zeigt."),
      _slide(
          context: context,
          title: "Stundenplan",
          description: "Im Stundenplan kannst du deine wöchentlichen "
              "Veranstaltungen wie z.B. Vorlesungen eintragen. Er funktioniert "
              "wie ein gewöhnlicher Schul-Stundenplan. Auf Wunsch kannst du "
              "die Veranstaltung auch im Kalender anzeigen lassen.",
          image: 'timetable',
          altText: "Bilder, die den Stundenplan und das Formular zum Erstellen "
              "einer neuen Veranstaltung zeigen."),
      _slide(
          context: context,
          title: "Statistik",
          description: "Die gelernte Zeit pro Woche wird dir in einem "
              "übersichtlichen Diagramm angezeigt.",
          image: 'statistics',
          altText: "Ein Bild, das die Statistik als Balkendiagramm zeigt."),
      _slide(
          context: context,
          title: "Profil & Einstellungen",
          description: "Auf der Profilseite findest du diverse Einstellungen, "
              "mit denen du die App effizienter nutzen und nach deinen Wünschen "
              "einrichten kannst.",
          image: 'profileSettings',
          altText: "Bilder, die die Profilseite und Einstellungen zeigen.")
    ];

    // Creates the tutorial
    return IntroSlider(
        slides: _slides,
        backgroundColorAllSlides: Theme.of(context).colorScheme.surface,
        sizeDot: MediaQuery.of(context).size.width / 55,
        colorDot: const Color(0xFFBDBDBD),
        colorActiveDot: Theme.of(context).colorScheme.primary,
        renderSkipBtn:
          const FittedBox(fit: BoxFit.scaleDown, child: Text("Überspringen")),
        renderNextBtn: const Icon(Icons.arrow_forward),
        renderDoneBtn:
          const FittedBox(fit: BoxFit.scaleDown, child: Text("Verstanden")),
        onSkipPress: () => _onDonePress(context),
        onDonePress: () => _onDonePress(context)
    );
  }
}
