import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/countries.dart';

class FlagQuizScreen extends StatefulWidget {
  const FlagQuizScreen({super.key});

  @override
  State<FlagQuizScreen> createState() => _FlagQuizScreenState();
}

class _FlagQuizScreenState extends State<FlagQuizScreen> {
  @override
  Widget build(BuildContext context) {
    final code = randomCountryCode().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.flags)),
      body: SafeArea(
        minimum: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(),
            SvgPicture.asset('assets/flags/$code.svg'),
            const Spacer(),
            MaterialButton(
              child: const Text('next'),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
