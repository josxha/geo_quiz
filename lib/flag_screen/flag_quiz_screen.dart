import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_quiz/game_screen/game_screen.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/countries.dart';

class FlagQuizScreen extends StatefulWidget {
  const FlagQuizScreen({super.key});

  @override
  State<FlagQuizScreen> createState() => _FlagQuizScreenState();
}

class _FlagQuizScreenState extends State<FlagQuizScreen> {
  final _stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    final code = randomCountryCode().toLowerCase();
    debugPrint(code);

    return GameScreen(
      stopwatch: _stopwatch,
      progress: '0/${countryCodes.length}',
      child: SafeArea(
        minimum: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset('assets/flags/$code.svg'),
              const Spacer(),
              Wrap(
                children: [
                  MaterialButton(
                    color: Colors.amber,
                    child: const Text('Next'),
                    onPressed: () => setState(() {}),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
