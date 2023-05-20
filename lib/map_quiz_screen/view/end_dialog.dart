import 'package:geo_quiz/shared/common.dart';

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
      title: Text(AppLocalizations.of(context)!.gameFinished),
      content: Table(
        children: [
          TableRow(
            children: [
              Text(AppLocalizations.of(context)!.correctGuesses),
              Text(correct.toString())
            ],
          ),
          TableRow(
            children: [
              Text(AppLocalizations.of(context)!.wrongGuesses),
              Text(wrong.toString())
            ],
          ),
          TableRow(
            children: [
              Text(AppLocalizations.of(context)!.timeNeeded),
              Text('${time.inMinutes}min ${time.inSeconds % 60}s')
            ],
          ),
        ],
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).pop(); // dismiss dialog
            context.replaceNamed(Routes.start);
          },
          child: Text(AppLocalizations.of(context)!.ok),
        )
      ],
    );
  }
}
