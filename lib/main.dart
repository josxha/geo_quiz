import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = MapController();
  late final Future<GeoJsonParser> _futureGeoJsonParser;

  Future<GeoJsonParser> _loadGeoJson() async {
    final geoJson = await rootBundle
        .loadString('assets/world-administrative-boundaries.json');
    final parser = GeoJsonParser();
    parser.parseGeoJsonAsString(geoJson);
    return parser;
  }

  @override
  void initState() {
    _futureGeoJsonParser = _loadGeoJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Geo Quiz"),
        ),
        body: FutureBuilder<GeoJsonParser>(
            future: _loadGeoJson(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                final geoJson = snapshot.data!;
                return FlutterMap(
                  mapController: _controller,
                  options: MapOptions(zoom: 3),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    PolygonLayer(polygons: geoJson.polygons),
                    PolylineLayer(polylines: geoJson.polylines),
                    MarkerLayer(markers: geoJson.markers),
                  ],
                );
              }
              if (snapshot.error != null) {
                debugPrint(snapshot.error.toString());
                debugPrintStack(stackTrace: snapshot.stackTrace);
                return Center(child: Text(snapshot.error!.toString()));
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
