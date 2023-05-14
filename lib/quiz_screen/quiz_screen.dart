import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
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
    final geoJson = await rootBundle.loadString('assets/countries.json');
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
    parser.parseGeoJsonAsString(geoJson);
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
                  //center: LatLng(0, 0),
                  zoom: 5,
                  maxZoom: 6,
                  minZoom: 1,
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                  maxBounds: LatLngBounds(
                    LatLng(-90, -180),
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
