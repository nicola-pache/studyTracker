import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Privacy as a stateless widget.
class Privacy extends StatelessWidget {
  const Privacy({Key? key}) : super(key: key);

  /// Builds the text for the privacy page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Datenschutz")
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                        text: TextSpan(
                            style: (TextStyle(
                              fontSize: 18.0,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            )),
                            children: const <TextSpan> [
                              TextSpan(
                                text: "Datenschutz",
                                style: (TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
                              ),
                              TextSpan(
                                  text: "\nDie Nutzung unserer Webseite ist in der Regel ohne Angabe "
                                      "personenbezogener Daten möglich. Soweit auf unseren Seiten "
                                      "personenbezogene Daten (beispielsweise Name, Anschrift oder "
                                      "eMail-Adressen) erhoben werden, erfolgt dies, soweit möglich, "
                                      "stets auf freiwilliger Basis. Diese Daten werden ohne Ihre "
                                      "ausdrückliche Zustimmung nicht an Dritte weitergegeben. "
                                      "\nWir weisen darauf hin, dass die Datenübertragung im Internet "
                                      "(z.B. bei der Kommunikation per E-Mail) Sicherheitslücken "
                                      "aufweisen kann. Ein lückenloser Schutz der Daten vor dem "
                                      "Zugriff durch Dritte ist nicht möglich.\nDer Nutzung von im "
                                      "Rahmen der Impressumspflicht veröffentlichten Kontaktdaten "
                                      "durch Dritte zur Übersendung von nicht ausdrücklich angeforderter "
                                      "Werbung und Informationsmaterialien wird hiermit ausdrücklich "
                                      "widersprochen. Die Betreiber der Seiten behalten sich ausdrücklich "
                                      "rechtliche Schritte im Falle der unverlangten Zusendung von "
                                      "Werbeinformationen, etwa durch Spam-Mails, vor."
                              )
                            ]
                        )
                    )
                  ],
                )
            )
        )
    );
  }

}