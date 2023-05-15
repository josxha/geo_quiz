import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/map_quiz_screen/country_polygon.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:point_in_polygon/point_in_polygon.dart';

class MapWidget extends StatefulWidget {
  final GeoJsonService geoJsonService;
  final void Function(String) onMapSelected;
  final Map<String, (CountryState, int)> states;

  const MapWidget({
    super.key,
    required this.geoJsonService,
    required this.onMapSelected,
    required this.states,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final _prefService = GetIt.I<PrefService>();
  final _controller = MapController();

  String? _countryMapSelection;

  late final _geoJsonParser = GeoJsonParser(
    polygonCreationCallback: (points, holePointsList, properties) {
      var state = widget.states[properties['name']]?.$1 ?? CountryState.unset;
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

  @override
  Widget build(BuildContext context) {
    _geoJsonParser.parseGeoJson(widget.geoJsonService.json);
    return ColoredBox(
      color: const Color.fromRGBO(170, 211, 223, 1),
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          zoom: 2.5,
          maxZoom: 6,
          minZoom: 1,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          maxBounds: LatLngBounds(
            LatLng(-60, -180),
            LatLng(90, 180),
          ),
          slideOnBoundaries: true,
          boundsOptions: const FitBoundsOptions(inside: true),
          onTap: (_, point) async => _onMapPressed(context, point),
        ),
        children: [
          // TileLayer(
          //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // ),
          PolygonLayer(
            polygons: _geoJsonParser.polygons,
            // polygonCulling: true, // throws exceptions on hot reload
          ),
          // PolylineLayer(polylines: geoJson.polylines),
          // MarkerLayer(markers: geoJson.markers),
        ],
      ),
    );
  }

  Future<void> _onMapPressed(
    BuildContext context,
    LatLng latLng,
  ) async {
    // find pressed country
    final point = Point(x: latLng.latitude, y: latLng.longitude);
    final polygon = _geoJsonParser.polygons.firstWhereOrNull((polygon) {
      final points = polygon.points
          .map((e) => Point(x: e.latitude, y: e.longitude))
          .toList(growable: false);
      return Poly.isPointInPolygon(point, points);
    }) as CountryPolygon?;
    if (polygon == null) {
      debugPrint('No country pressed');
      return;
    }
    debugPrint(_countryMapSelection);
    setState(() {
      _countryMapSelection = polygon.properties['name'].toString();
    });
    widget.onMapSelected(_countryMapSelection!);
  }
}
