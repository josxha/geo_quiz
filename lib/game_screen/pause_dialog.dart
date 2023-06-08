import 'package:geo_quiz/shared/common.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.gamePaused),
      content: Text(AppLocalizations.of(context)!.gamePausedText),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          color: Colors.lightGreen,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.continuePlaying),
          ),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          color: Colors.redAccent,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.endGame),
          ),
        ),
      ],
    );
  }
}
