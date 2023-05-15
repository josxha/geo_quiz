import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geo_quiz/shared/routes.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.6,
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  'GeoQuiz',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => Routes.mapQuiz.push(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle),
                              const SizedBox(width: 16),
                              Text(
                                AppLocalizations.of(context)!.startGame,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Routes.flagQuiz.push(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle),
                              const SizedBox(width: 16),
                              Text(
                                AppLocalizations.of(context)!.startGame,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Routes.settings.push(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.settings),
                              const SizedBox(width: 16),
                              Text(
                                AppLocalizations.of(context)!.settings,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Routes.about.push(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.help),
                              const SizedBox(width: 16),
                              Text(
                                AppLocalizations.of(context)!.aboutTheApp,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
