import 'package:geo_quiz/shared/common.dart';

class CountrySelectionText extends StatelessWidget {
  final String text;

  const CountrySelectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          AppLocalizations.of(context)!.selectedCountry(text),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
