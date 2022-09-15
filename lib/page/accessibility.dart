import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Accessibility as a stateless widget.
class Accessibility extends StatelessWidget {
  const Accessibility({Key? key}) : super(key: key);

  /// Builds the text for the accessibility page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Barrierefreiheit')),
        body: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
          RichText(
            text: TextSpan(
              style: (TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
                fontWeight: FontWeight.normal,
              )),
              children: const <TextSpan>[
                TextSpan(
                    text: "Erklärung zur Barrierefreiheit - studyTracker",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\n\nstudyTracker setzt sich dafür ein, die digitale Barrierefreiheit für Menschen mit Behinderungen zu gewährleisten. Wir verbessern kontinuierlich die Benutzerfreundlichkeit für alle und wenden die entsprechenden Standards für die Zugänglichkeit an."),
                TextSpan(
                    text: "\n\nKonformitätsstatus",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\n\nAktueller Standard der Barrierefreiheit der Website:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(text: "\nWCAG 2.1 Level AA"),
                TextSpan(
                    text: "\n\nAktueller Status der Inhaltskonformität:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nTeilweise konform: Einige Teile des Inhalts entsprechen nicht vollständig dem Standard für Barrierefreiheit."),
                TextSpan(
                    text: "\n\nNicht Barrierefreie Inhalte",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nTrotz unserer Bemühungen können bei den Benutzern einige Probleme auftreten. Dies ist eine Beschreibung der bekannten Probleme bei der Barrierefreiheit. Bitte kontaktieren Sie uns, wenn Sie ein Problem beobachten, das nicht aufgeführt ist."),
                TextSpan(
                    text: "\n\nStatistik:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nUnsere Statistiken können derzeit nicht vollständig durch ScreenReader ausgelesen werden."),
                TextSpan(
                    text: "\n\nKontrast:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nEs ist möglich, dass das Kontrastverhältnis von Hintergrund- und Vordergrundfarben nicht gegeben ist"),
                TextSpan(
                    text:
                        "\n\nWir arbeiten daran, diese Barrieren zu vermindern und zu beheben."),
                TextSpan(
                    text: "\n\nTechnologien",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nDie Barrierefreiheit dieser App hängt von den folgenden Technologien ab, um zu funktionieren:"
                        "\n  - Android 11"
                        "\n  - IOS 14.4"),
                TextSpan(
                    text: "\n\nBewertungsmethoden",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nDie Barrierefreiheit dieser App wird mit Hilfe der folgender Methode bewertet: "
                        "\nSelbsteinschätzung: Die App wurde intern vom studyTracker-Team bewertet."),
                TextSpan(
                    text: "\n\nFeedback-Prozess",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nWir freuen uns über Ihr Feedback zur Barrierefreiheit dieser App. Bitte kontaktieren Sie uns auf eine der folgenden Arten: "
                        "\n\nTelefon: XXXX XXXXXXX"
                        "\nE-Mail: M.Mustermann@domain.de"
                        "\nAnschrift: Musterstraße XX, XXXX Musterstadt"
                        "\n\nWir sind bestrebt, Ihnen eine Rückmeldungen innerhalb von 6 Wochen zu geben."),
                TextSpan(
                    text:
                        "\n\nDiese Erklärung zur Barrierefreiheit wird genehmigt von:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nSollten Sie auf Ihre Mitteilung oder Anfrage zur Barrierefreiheit innerhalb von sechs Wochen keine zufriedenstellende Antwort erhalten haben, können Sie die Ombudsstelle für barrierefreie Informationstechnik einschalten. Sie ist der oder dem Beauftragten für die Belange der Menschen mit Behinderung nach § 11 des Behinderten-gleichstellungsgesetzes Nordrhein-Westfalen sowie §§ 10d, 10e BGG NRW und §§ 9 ff der BITV NRW zugeordnet. "
                        "\n\nDas Schlichtungsverfahren ist kostenlos. Ein Rechtsbeistand ist nicht erforderlich. "
                        "\n\nSollten Sie ein Ombudsverfahren wünschen, füllen Sie bitte den Antrag aus und senden ihn per E-Mail an die Ombudsstelle: "
                        "\nombudsstelle-barrierefreie-it(at)mags.nrw.de "
                        "\n\nOmbudsstelle für barrierefreie Informationstechnik des Landes Nordrhein-Westfalen "
                        "\nbei der Landesbeauftragten für Menschen mit Behinderungen "
                        "\nFürstenwall 25 "
                        "\n40219 Düsseldorf "
                        "\n\nTelefonnummer: 0211 855-3451 "),
                TextSpan(
                    text:
                        "\n\nFormelle Genehmigung dieser Erklärung zur Barrierefreiheit",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        "\nThis accessibility statement is approved by: \nstudyTracker \nJulienne Szlapa"),
                TextSpan(
                    text:
                        "\n\nDiese Erklärung zur Barrierefreiheit wurde am 19.01.2022 erstellt" /*+ "und zuletzt am 19.01.2022 überprüft"*/ +
                            "."),
              ],
            ),
          ),
        ]));
  }
}
