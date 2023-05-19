import 'dart:math';

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
  final _random = Random.secure();
  late final List<Country> countries = parseCountries()..shuffle(_random);
  late final int totalCountries = countries.length;
  var _counter = 0;
  final _amountAnswers = 4;

  bool? _answeredCorrectly;
  late List<int> _selectedIndexes;
  late int _correctIndex;

  Country get _correctCountry => countries[_correctIndex];

  void newFlag() {
    _answeredCorrectly = null;
    _selectedIndexes = List.generate(
      _amountAnswers,
      (index) => _random.nextInt(countries.length),
    );
    _correctIndex = _selectedIndexes[_random.nextInt(_amountAnswers)];
    debugPrint(_correctCountry.toString());
  }

  @override
  void initState() {
    print('initState');
    newFlag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      stopwatch: _stopwatch,
      progress: '$_counter/$totalCountries',
      child: SafeArea(
        minimum: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/flags/${_correctCountry.code.toLowerCase()}.svg',
              ),
              const Spacer(),
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: _selectedIndexes.map((e) {
                  final country = countries[e];
                  final isCorrectButton = country.code == _correctCountry.code;
                  return MaterialButton(
                    color: (isCorrectButton && _answeredCorrectly != null)
                        ? switch (_answeredCorrectly) {
                            true => Colors.lightGreen,
                            false => Colors.redAccent,
                            _ => Colors.blueAccent,
                          }
                        : null,
                    child: Text(country.name),
                    onPressed: () async {
                      setState(() {
                        _answeredCorrectly =
                            country.code == _correctCountry.code;
                        if (_answeredCorrectly ?? false) {
                          _counter++;
                        }
                      });
                      await Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          countries.removeAt(_correctIndex);
                          newFlag();
                        });
                      });
                    },
                  );
                }).toList(growable: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
