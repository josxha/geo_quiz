import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geo_quiz/shared/routes.dart';
import 'package:geo_quiz/start_screen/about_app_dialog.dart';
import 'package:geo_quiz/start_screen/menu_button.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonData = [
      (
        () => context.pushNamed(Routes.mapQuiz),
        FontAwesomeIcons.map,
        AppLocalizations.of(context)!.startGame,
      ),
      (
        () => context.pushNamed(Routes.flagQuiz),
        FontAwesomeIcons.flag,
        AppLocalizations.of(context)!.startGame,
      ),
      (
        () => context.pushNamed(Routes.highScores),
        FontAwesomeIcons.trophy,
        AppLocalizations.of(context)!.highScores,
      ),
      (
        () => context.pushNamed(Routes.settings),
        FontAwesomeIcons.gear,
        AppLocalizations.of(context)!.settings
      ),
      (
        () async => showDialog(
              context: context,
              builder: (_) => const AboutAppDialog(),
            ),
        FontAwesomeIcons.question,
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
              itemCount: buttonData.length + 2,
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
                if (index == buttonData.length + 1) {
                  return const SizedBox(height: 32);
                }
                final button = buttonData[index - 1];
                return MenuButton(
                  onTap: button.$1,
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
