import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/quiz_screen/country_polygon.dart';
import 'package:geo_quiz/quiz_screen/result_dialog.dart';
import 'package:geo_quiz/shared/routes.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:geo_quiz/shared/services/pref_service.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:point_in_polygon/point_in_polygon.dart';

class QuizScreen extends StatefulWidget {
  final bool showOsm;

  const QuizScreen({
    this.showOsm = false,
    super.key,
  });

  @override
  State<QuizScreen> createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final _prefService = GetIt.I<PrefService>();
  final _controller = MapController();
  final _states = <String, (CountryState, int)>{};
  late Future<GeoJsonParser> _futureGeoJson;
  late final DateTime _startTime;

  String? _selection;

  Future<GeoJsonParser> _loadGeoJson() async {
    final parser = GeoJsonParser(
      polygonCreationCallback: (points, holePointsList, properties) {
        return CountryPolygon(
          points: points,
          holePointsList: holePointsList,
          properties: properties,
          state: _states[properties['name']]?.$1 ?? CountryState.unset,
          //showLabel: true,
        );
      },
    );
    final geoJsonService = await GetIt.I.getAsync<GeoJsonService>();
    parser.parseGeoJson(geoJsonService.json);
    return parser;
  }

  @override
  void initState() {
    _startTime = DateTime.now();
    _futureGeoJson = _loadGeoJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeoJsonParser>(
      future: _futureGeoJson,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final geoJsonParser = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (_prefService.showTime)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_alarm),
                        const SizedBox(width: 8),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final duration =
                                DateTime.now().difference(_startTime);
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
                      const Icon(Icons.stacked_bar_chart_outlined),
                      const SizedBox(width: 8),
                      Text(
                        '${_states.values.where((e) => e.$1.isFinished()).length}/'
                        '${geoJsonParser.polygons.length}',
                      ),
                    ],
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: const Text('Country list'),
              icon: const Icon(Icons.flag),
              onPressed: _onCountryListButtonClicked,
            ),
            body: Column(
              children: [
                if (_selection != null)
                  ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Ausgewählt: $_selection',
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
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        maxBounds: LatLngBounds(
                          LatLng(-60, -180),
                          LatLng(90, 180),
                        ),
                        slideOnBoundaries: true,
                        boundsOptions: const FitBoundsOptions(inside: true),
                        onTap: (_, point) async =>
                            _onMapPressed(context, geoJsonParser, point),
                      ),
                      children: [
                        if (widget.showOsm)
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                        PolygonLayer(
                          polygons: geoJsonParser.polygons,
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
      countries,
    ) as String?;
  }

  Future<void> _onMapPressed(
    BuildContext context,
    GeoJsonParser parser,
    LatLng latLng,
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
    final clickedCountry = polygon.properties['name'].toString();
    debugPrint(clickedCountry);

    // abort if guessed too much
    final state = _states[clickedCountry];
    final attempts = state?.$2 ?? 0;
    if (attempts >= _prefService.maxTries) return;
    if (state?.$1.isFinished() ?? false) return;

    // get guess if selection is null
    if (_selection == null) {
      final selection = await _openCountryList();
      _selection = selection;
    }
    if (_selection == null) return;

    // check and show the result
    final isCorrect = _selection == clickedCountry;
    _addAttempt(parser, clickedCountry, isCorrect);
    setState(() => _selection = null);
    final sms = ScaffoldMessenger.of(context);
    sms.clearSnackBars();
    sms.showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Unfortunately wrong...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isCorrect ? Colors.lightGreen : Colors.redAccent,
      ),
    );
  }

  Future<void> _onCountryListButtonClicked() async {
    final selection = await _openCountryList();
    setState(() => _selection = selection);
  }

  void _addAttempt(GeoJsonParser parser, String country, bool isCorrect) {
    final state = _states[country];
    final previousAttempts = state?.$2 ?? 0;
    final currentAttempts = previousAttempts + 1;
    if (isCorrect) {
      _states[country] = (CountryState.correct, currentAttempts);
    } else if (currentAttempts >= _prefService.maxTries) {
      _states[country] = (CountryState.wrong, currentAttempts);
    } else {
      _states[country] = (CountryState.tried, currentAttempts);
    }
    setState(() {
      _futureGeoJson = _loadGeoJson();
    });

    // end dialog
    if (_states.length == parser.polygons.length) {
      showDialog(
        context: context,
        builder: (context) => EndDialog(
          correct:
              _states.values.where((e) => e.$1 == CountryState.correct).length,
          wrong: _states.values.where((e) => e.$1 == CountryState.wrong).length,
          time: DateTime.now().difference(_startTime),
        ),
      );
    }
  }
}
