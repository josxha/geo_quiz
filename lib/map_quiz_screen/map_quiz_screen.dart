import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/country_list/country_list.dart';
import 'package:geo_quiz/country_list/country_list_content.dart';
import 'package:geo_quiz/map_quiz_screen/country_polygon.dart';
import 'package:geo_quiz/map_quiz_screen/end_dialog.dart';
import 'package:geo_quiz/map_quiz_screen/pause_dialog.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:point_in_polygon/point_in_polygon.dart';

class MapQuizScreen extends StatefulWidget {
  final bool showOsm;

  const MapQuizScreen({
    this.showOsm = false,
    super.key,
  });

  @override
  State<MapQuizScreen> createState() => MapQuizScreenState();
}

class MapQuizScreenState extends State<MapQuizScreen> {
  final _prefService = GetIt.I<PrefService>();
  final _controller = MapController();
  final _states = <String, (CountryState, int)>{};
  final _stopwatch = Stopwatch();
  var _gamePaused = false;

  String? _countryNameSelection;
  String? _countryMapSelection;

  @override
  void initState() {
    _stopwatch.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bigScreen = size.width > 900;

    return FutureBuilder<GeoJsonService>(
      future: GetIt.I.getAsync<GeoJsonService>(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final geoJsonService = snapshot.data!;

          final parser = GeoJsonParser(
            polygonCreationCallback: (points, holePointsList, properties) {
              var state = _states[properties['name']]?.$1 ?? CountryState.unset;
              if (properties['name'] == _countryMapSelection) {
                state = CountryState.selected;
              }
              return CountryPolygon(
                points: points,
                holePointsList: holePointsList,
                properties: properties,
                state: state,
                showLabel: _prefService.labelCountriesAfterFinished
                    ? ShowLabel.ifFinished
                    : ShowLabel.never,
              );
            },
          );
          parser.parseGeoJson(geoJsonService.json);

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: AppBar(
                title: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    if (_prefService.showTime)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(FontAwesomeIcons.clock),
                          const SizedBox(width: 8),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final duration = _stopwatch.elapsed;
                              final min = duration.inMinutes;
                              final sec = (duration.inSeconds % 60)
                                  .toString()
                                  .padLeft(2, '0');
                              return Text('$min:$sec');
                            },
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.chartLine),
                        const SizedBox(width: 8),
                        Text(
                          '${_states.values.where((e) => e.$1.isFinished()).length}/'
                          '${parser.polygons.length}',
                        ),
                      ],
                    )
                  ],
                ),
              ),
              floatingActionButton: bigScreen
                  ? null
                  : FloatingActionButton.extended(
                      label: Text(AppLocalizations.of(context)!.countryNames),
                      icon: const FaIcon(FontAwesomeIcons.flag),
                      onPressed: _onCountryListButtonClicked,
                    ),
              body: Row(
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
                          child: ColoredBox(
                            color: const Color.fromRGBO(170, 211, 223, 1),
                            child: FlutterMap(
                              mapController: _controller,
                              options: MapOptions(
                                zoom: 2.5,
                                maxZoom: 6,
                                minZoom: 1,
                                interactiveFlags: InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                                maxBounds: LatLngBounds(
                                  LatLng(-60, -180),
                                  LatLng(90, 180),
                                ),
                                slideOnBoundaries: true,
                                boundsOptions:
                                    const FitBoundsOptions(inside: true),
                                onTap: (_, point) async => _onMapPressed(
                                  context,
                                  parser,
                                  point,
                                  bigScreen,
                                ),
                              ),
                              children: [
                                if (widget.showOsm)
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  ),
                                PolygonLayer(
                                  polygons: parser.polygons,
                                  // polygonCulling: true, // throws exceptions of hot reload
                                ),
                                // PolylineLayer(polylines: geoJson.polylines),
                                // MarkerLayer(markers: geoJson.markers),
                              ],
                            ),
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
                                  .whereNot((e) =>
                                      _states[e]?.$1.isFinished() ?? false)
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
                                _addAttempt(parser);
                              },
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                ],
              ),
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

  Future<void> _onMapPressed(
    BuildContext context,
    GeoJsonParser parser,
    LatLng latLng,
    bool isBigScreen,
  ) async {
    // find pressed country
    final point = Point(x: latLng.latitude, y: latLng.longitude);
    final polygon = parser.polygons.firstWhereOrNull((polygon) {
      final points = polygon.points
          .map((e) => Point(x: e.latitude, y: e.longitude))
          .toList(growable: false);
      return Poly.isPointInPolygon(point, points);
    }) as CountryPolygon?;
    if (polygon == null) {
      debugPrint('No country pressed');
      return;
    }
    setState(() {
      _countryMapSelection = polygon.properties['name'].toString();
    });
    debugPrint(_countryMapSelection);

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
      }
    }
    if (_countryNameSelection == null) return;

    // check and show the result
    _addAttempt(parser);
  }

  Future<void> _onCountryListButtonClicked() async {
    final selection = await _openCountryList();
    setState(() => _countryNameSelection = selection);
  }

  void _addAttempt(GeoJsonParser parser) {
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
    setState(() {
      if (isCorrect) {
        _states[_countryMapSelection!] =
            (CountryState.correct, currentAttempts);
      } else if (currentAttempts >= _prefService.maxTries) {
        _states[_countryMapSelection!] = (CountryState.wrong, currentAttempts);
      } else {
        _states[_countryMapSelection!] = (CountryState.tried, currentAttempts);
      }
    });

    // clear selection
    setState(() {
      _countryNameSelection = null;
      _countryMapSelection = null;
    });

    // end dialog
    if (_states.length == parser.polygons.length) {
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

  Future<bool> _onWillPop() async {
    if (_gamePaused) return true;

    _gamePaused = true;
    _stopwatch.stop();

    final continueGame = await showDialog(
          context: context,
          builder: (context) => const PauseDialog(),
        ) as bool? ??
        true;
    // debugPrint('continue game: $continueGame');
    if (continueGame) {
      _gamePaused = false;
      _stopwatch.start();
      return false;
    }
    return true;
  }
}
