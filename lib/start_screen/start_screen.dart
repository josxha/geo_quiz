import 'package:flutter/material.dart';
import 'package:geo_quiz/routes.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => Routes.quiz.push(),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow),
                    Spacer(),
                    Text(
                      'Spiel starten',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => Routes.settings.push(),
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    Spacer(),
                    Text(
                      'Einstellungen',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
