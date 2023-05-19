import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_quiz/game_screen/game_screen.dart';
import 'package:geo_quiz/map_quiz_screen/end_dialog.dart';
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
  static const _amountAnswers = 4;
  late final List<Country> _countriesTotal = parseCountries()..shuffle(_random);
  late final List<Country> _countriesQueue = List.of(_countriesTotal);
  final _countriesWrong = <Country>[];

  var _correctCounter = 0;

  bool? _guessedCorrectly;
  late List<Country> _selectedCountries;
  late Country _correctCountry;

  int get _amountGuessedWrong => _countriesWrong.length;

  int get _amountTotal => _countriesTotal.length;

  void newFlag() {
    _guessedCorrectly = null;
    _correctCountry = _countriesQueue[_random.nextInt(_countriesQueue.length)];
    debugPrint(_correctCountry.toString());
    final selected = <Country>{_correctCountry};
    while (selected.length < _amountAnswers) {
      final randomCountry =
          _countriesTotal[_random.nextInt(_countriesTotal.length)];
      selected.add(randomCountry);
    }
    _selectedCountries = selected.toList(growable: false);
    _selectedCountries.shuffle(_random);
  }

  @override
  void initState() {
    newFlag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      stopwatch: _stopwatch,
      progress: _correctCounter / _amountTotal,
      errors: _amountGuessedWrong,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.6,
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
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
                  children: _selectedCountries.map((e) {
                    final isCorrectButton = e.code == _correctCountry.code;
                    return MaterialButton(
                      color: (isCorrectButton && _guessedCorrectly != null)
                          ? switch (_guessedCorrectly) {
                              true => Colors.lightGreen,
                              false => Colors.redAccent,
                              _ => Colors.white,
                            }
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(e.name),
                      ),
                      onPressed: () async => _onButtonClicked(e),
                    );
                  }).toList(growable: false),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onButtonClicked(Country country) async {
    setState(() {
      _guessedCorrectly = country.code == _correctCountry.code;
      if (_guessedCorrectly ?? false) {
        _correctCounter++;
      } else {
        _countriesWrong.add(country);
      }
    });
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _countriesQueue.remove(_correctCountry);
        newFlag();
      });
    });

    // end dialog
    if (_countriesQueue.length == _amountTotal) {
      _stopwatch.stop();
      await showDialog(
        context: context,
        builder: (context) => EndDialog(
          correct: _amountTotal,
          wrong: _amountGuessedWrong,
          time: _stopwatch.elapsed,
        ),
      );
    }
  }
}
