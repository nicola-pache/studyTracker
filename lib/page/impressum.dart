import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Impressum as a stateless widget.
class Impressum extends StatelessWidget {
  const Impressum({Key? key}) : super(key: key);

  /// Builds the text for the Impressum.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impressum")
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
                            text: "Angaben gemäß § 5 TMG"
                                "\n\nMax Muster"
                                "\nMusterweg"
                                "\n12345 Musterstadt"
                        ),
                        TextSpan(
                          text: "\n\nVertreten durch:",
                          style: (TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
                        ),
                        TextSpan(
                          text: "\nNadine Christ"
                              "\nJulienne Szlapa"
                              "\nNicola Pache"
                        ),
                        TextSpan(
                          text: "\n\nKontakt:",
                          style: (TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
                        ),
                        TextSpan(
                          text: "\nTelefon: 01234-789456"
                              "\nFax: 1234-56789"
                              "\nE-Mail: max@muster.de"
                        ),
                        TextSpan(
                          text: "\n\nHaftungsausschluss:\nUrheberrecht",
                          style: (TextStyle(fontWeight: FontWeight.bold, height: 2.0)),
                        ),
                        TextSpan(
                          text:
                              "\nDie durch die Seitenbetreiber erstellten Inhalte und Werke "
                                  "auf diesen Seiten unterliegen dem deutschen Urheberrecht. "
                                  "Die Vervielfältigung, Bearbeitung, Verbreitung und jede "
                                  "Art der Verwertung außerhalb der Grenzen des "
                                  "Urheberrechtes bedürfen der schriftlichen Zustimmung des "
                                  "jeweiligen Autors bzw. Erstellers. Downloads und Kopien "
                                  "dieser Seite sind nur für den privaten, nicht kommerziellen "
                                  "Gebrauch gestattet. Soweit die Inhalte auf dieser Seite nicht "
                                  "vom Betreiber erstellt wurden, werden die Urheberrechte Dritter "
                                  "beachtet. Insbesondere werden Inhalte Dritter als solche "
                                  "gekennzeichnet. Sollten Sie trotzdem auf eine Urheberrechtsverletzung "
                                  "aufmerksam werden, bitten wir um einen entsprechenden Hinweis. "
                                  "Bei Bekanntwerden von Rechtsverletzungen werden wir derartige "
                                  "Inhalte umgehend entfernen."
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