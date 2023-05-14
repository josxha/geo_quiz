import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
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
  final _controller = MapController();

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
        );
      },
    );
    final service = await GetIt.I.getAsync<GeoJsonService>();
    parser.parseGeoJson(service.json);
    return parser;
  }

  @override
  void initState() {
    //_futureGeoJsonParser = _loadGeoJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Quiz'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Landesnamen'),
        icon: const Icon(Icons.flag),
        onPressed: () {},
      ),
      body: FutureBuilder<GeoJsonParser>(
        future: _loadGeoJson(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final geoJson = snapshot.data!;
            return ColoredBox(
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
            );
          }
          if (snapshot.error != null) {
            debugPrint(snapshot.error.toString());
            debugPrintStack(stackTrace: snapshot.stackTrace);
            return Center(child: Text(snapshot.error!.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
