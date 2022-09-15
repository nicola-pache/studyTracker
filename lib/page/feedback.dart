import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Feedback as a stateless widget.
/// Name needed to be different from just *feedback* because there already
/// is a standard flutter package called feedback.
class FeedbackST extends StatelessWidget {
  const FeedbackST({Key? key}) : super(key: key);

  /// Builds the text for the feedback page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: RichText(
            text: TextSpan(
              style: (TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
                fontWeight: FontWeight.normal,
              )),
              children: const <TextSpan> [
                TextSpan(
                  text: "Feedback und Problemberichte bitte per E-Mail an:"
                      "\n\nstudytracker.app@gmail.com"
                )
              ]
            )
          )
        )
      ),
    );
  }
}