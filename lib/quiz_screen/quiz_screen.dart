import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/shared/routes.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:geo_quiz/shared/services/pref_service.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';

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
  late final DateTime _startTime;

  String? _selection;

  //late final Future<GeoJsonParser> _futureGeoJsonParser;

  Future<GeoJsonParser> _loadGeoJson() async {
    final parser = GeoJsonParser(
      polygonCreationCallback: (points, holePointsList, properties) {
        return Polygon(
          points: points,
          color: Colors.lightGreen,
          borderStrokeWidth: 0.5,
          borderColor: Colors.black,
          isFilled: true,
          //label: properties['name'],
        );
      },
    );
    final geoJsonService = await GetIt.I.getAsync<GeoJsonService>();
    parser.parseGeoJson(geoJsonService.json);
    return parser;
  }

  @override
  void initState() {
    //_futureGeoJsonParser = _loadGeoJson();
    _startTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeoJsonParser>(
      future: _loadGeoJson(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final geoJson = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Wrap(
                children: [
                  if (_prefService.showTime) ...[
                    const Icon(Icons.access_alarm),
                    const SizedBox(width: 8),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final duration = DateTime.now().difference(_startTime);
                        final min = duration.inMinutes;
                        final sec = (duration.inSeconds % 60)
                            .toString()
                            .padLeft(2, '0');
                        return Text('$min:$sec');
                      },
                    ),
                  ],
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: const Text('Ländernamen'),
              icon: const Icon(Icons.flag),
              onPressed: _openCountryList,
            ),
            body: ColoredBox(
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
                ),
                children: [
                  if (widget.showOsm)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                  PolygonLayer(
                    polygons: geoJson.polygons,
                    // polygonCulling: true, // throws exceptions of hot reload
                  ),
                  // PolylineLayer(polylines: geoJson.polylines),
                  // MarkerLayer(markers: geoJson.markers),
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

  Future<void> _openCountryList() async {
    final service = await GetIt.I.getAsync<GeoJsonService>();
    final jsonList = service.json['features'] as List<dynamic>;
    final countries = jsonList
        .map((e) => e['properties']['name'] as String)
        .sorted()
        .toList(growable: false);
    _selection = await Routes.countryList.push(
      Navigator.of(context),
      countries,
    ) as String?;
  }
}
