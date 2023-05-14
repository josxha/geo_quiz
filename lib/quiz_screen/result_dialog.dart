import 'package:flutter/material.dart';
import 'package:geo_quiz/shared/routes.dart';

class EndDialog extends StatelessWidget {
  final int correct;
  final int wrong;
  final Duration time;

  const EndDialog({
    super.key,
    required this.correct,
    required this.wrong,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game finished!'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Correct guesses: $correct'),
          Text('Wrong guesses: $wrong'),
          Text('Amount of time: ${time.inMinutes}min ${time.inSeconds % 60}s'),
        ],
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) {
              return route.settings.name == Routes.start.name;
            });
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}
