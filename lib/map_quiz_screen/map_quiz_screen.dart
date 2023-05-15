import 'dart:async';

import 'package:collection/collection.dart';
import 'package:geo_quiz/country_list/country_list.dart';
import 'package:geo_quiz/country_list/country_list_content.dart';
import 'package:geo_quiz/game_screen/game_screen.dart';
import 'package:geo_quiz/map_quiz_screen/country_polygon.dart';
import 'package:geo_quiz/map_quiz_screen/end_dialog.dart';
import 'package:geo_quiz/map_quiz_screen/map_widget.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';

class MapQuizScreen extends StatefulWidget {
  const MapQuizScreen({super.key});

  @override
  State<MapQuizScreen> createState() => MapQuizScreenState();
}

class MapQuizScreenState extends State<MapQuizScreen> {
  final _prefService = GetIt.I<PrefService>();
  final _mapKey = GlobalKey<MapWidgetState>();
  final _stopwatch = Stopwatch();

  final _states = <String, (CountryState, int)>{};

  String? _countryNameSelection;
  String? _countryMapSelection;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bigScreen = size.width > 900;

    return FutureBuilder<GeoJsonService>(
      future: GetIt.I.getAsync<GeoJsonService>(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final geoJsonService = snapshot.data!;
          return GameScreen(
            stopwatch: _stopwatch,
            progress:
                '${_states.values.where((e) => e.$1.isFinished()).length}/'
                '${geoJsonService.features.length}',
            floatingActionButton: bigScreen
                ? null
                : FloatingActionButton.extended(
                    label: Text(AppLocalizations.of(context)!.countryNames),
                    icon: const FaIcon(FontAwesomeIcons.flag),
                    onPressed: _onCountryListButtonClicked,
                  ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (!bigScreen && _countryNameSelection != null)
                        ColoredBox(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .selectedCountry(_countryNameSelection!),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      Expanded(
                        child: MapWidget(
                          key: _mapKey,
                          geoJsonService: geoJsonService,
                          onMapSelected: (sel) async => _onMapSelected(
                            sel,
                            bigScreen,
                            geoJsonService,
                          ),
                          states: _states,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bigScreen)
                  SizedBox(
                    width: 300,
                    child: FutureBuilder<GeoJsonService>(
                      future: GetIt.I.getAsync<GeoJsonService>(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return CountryListContent(
                            countries: snapshot.data!.features
                                .map((e) => e['properties']['name'] as String)
                                .whereNot(
                                  (e) => _states[e]?.$1.isFinished() ?? false,
                                )
                                .sorted()
                                .toList(growable: false),
                            selection: _countryNameSelection,
                            onSelected: (selection) {
                              if (_countryMapSelection == null) {
                                setState(() {
                                  _countryNameSelection = selection;
                                });
                                return;
                              }
                              _addAttempt(geoJsonService);
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
              ],
            ),
          );
        }
        if (snapshot.error != null) {
          debugPrint(snapshot.error.toString());
          debugPrintStack(stackTrace: snapshot.stackTrace);
          return Center(child: Text(snapshot.error!.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<String?> _openCountryList() async {
    final service = await GetIt.I.getAsync<GeoJsonService>();
    final countries = service.features
        .map((e) => e['properties']['name'] as String)
        .whereNot((e) => _states[e]?.$1.isFinished() ?? false)
        .sorted()
        .toList(growable: false);
    return await Routes.countryList.push(
      Navigator.of(context),
      CountryListArgs(countries, _countryNameSelection),
    ) as String?;
  }

  Future<void> _onCountryListButtonClicked() async {
    final selection = await _openCountryList();
    setState(() => _countryNameSelection = selection);
  }

  void _addAttempt(GeoJsonService geoJsonService) {
    final isCorrect = _countryNameSelection == _countryMapSelection &&
        _countryMapSelection != null;

    // show snackbar
    final sms = ScaffoldMessenger.of(context);
    sms.clearSnackBars();
    sms.showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? AppLocalizations.of(context)!.correctAnswer
              : AppLocalizations.of(context)!.wrongAnswer,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isCorrect ? Colors.lightGreen : Colors.redAccent,
      ),
    );

    // save attempt
    final state = _states[_countryMapSelection];
    final previousAttempts = state?.$2 ?? 0;
    final currentAttempts = previousAttempts + 1;
    if (isCorrect) {
      _states[_countryMapSelection!] = (CountryState.correct, currentAttempts);
    } else if (currentAttempts >= _prefService.maxTries) {
      _states[_countryMapSelection!] = (CountryState.wrong, currentAttempts);
    } else {
      _states[_countryMapSelection!] = (CountryState.tried, currentAttempts);
    }

    // clear selection
    setState(() {
      _countryNameSelection = null;
      _countryMapSelection = null;
    });
    _mapKey.currentState!.reloadPolygons();

    // end dialog
    if (_states.length == geoJsonService.features.length) {
      showDialog(
        context: context,
        builder: (context) => EndDialog(
          correct:
              _states.values.where((e) => e.$1 == CountryState.correct).length,
          wrong: _states.values.where((e) => e.$1 == CountryState.wrong).length,
          time: _stopwatch.elapsed,
        ),
      );
    }
  }

  Future<void> _onMapSelected(
    String mapSelection,
    bool isBigScreen,
    GeoJsonService geoJsonService,
  ) async {
    _countryMapSelection = mapSelection;

    // abort if guessed too much
    final state = _states[_countryMapSelection];
    final attempts = state?.$2 ?? 0;
    if (attempts >= _prefService.maxTries) return;
    if (state?.$1.isFinished() ?? false) return;

    // get guess if selection is null
    if (_countryNameSelection == null) {
      if (!isBigScreen) {
        // open country list page
        final selection = await _openCountryList();
        _countryNameSelection = selection;
      } else {
        _mapKey.currentState!.reloadPolygons();
      }
    }
    if (_countryNameSelection == null) return;

    // check and show the result
    _addAttempt(geoJsonService);
  }
}
