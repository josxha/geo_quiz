import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geo_quiz/shared/routes.dart';
import 'package:geo_quiz/start_screen/menu_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonData = [
      (
        Routes.mapQuiz,
        Icons.play_circle_outline,
        AppLocalizations.of(context)!.startGame,
      ),
      (
        Routes.flagQuiz,
        Icons.play_circle_outline,
        AppLocalizations.of(context)!.startGame,
      ),
      (
        Routes.highScores,
        FontAwesomeIcons.trophy,
        AppLocalizations.of(context)!.startGame,
      ),
      (
        Routes.settings,
        Icons.settings_outlined,
        AppLocalizations.of(context)!.settings
      ),
      (
        Routes.about,
        Icons.help_outline,
        AppLocalizations.of(context)!.aboutTheApp,
      ),
    ];

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
          minimum: const EdgeInsets.only(top: 16),
          child: Center(
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: buttonData.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 64, bottom: 16),
                    child: Text(
                      'GeoQuiz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }
                final button = buttonData[index - 1];
                return MenuButton(
                  route: button.$1,
                  iconData: button.$2,
                  label: button.$3,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
