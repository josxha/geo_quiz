import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_polygon.dart';
import 'package:geo_quiz/map_quiz_screen/provider/game_state.dart';
import 'package:geo_quiz/map_quiz_screen/view/country_list.dart';
import 'package:geo_quiz/map_quiz_screen/view/end_dialog.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:latlong2/latlong.dart';
import 'package:point_in_polygon/point_in_polygon.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key});

  @override
  ConsumerState<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends ConsumerState<MapWidget> {
  final _controller = MapController();

  @override
  void initState() {
    final gameState = ref.read(mapGameStateProvider);
    gameState.reloadMapPolygons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bigScreen = size.width > 900;
    final gameState = ref.watch(mapGameStateProvider);
    return ColoredBox(
      color: const Color.fromRGBO(170, 211, 223, 1),
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          zoom: gameState.lastZoom,
          maxZoom: 15,
          minZoom: 1,
          interactiveFlags: InteractiveFlag.all &
              ~InteractiveFlag.rotate &
              ~InteractiveFlag.doubleTapZoom,
          /*maxBounds: LatLngBounds(
            const LatLng(-60, -180),
            const LatLng(90, 180),
          ),*/
          slideOnBoundaries: true,
          boundsOptions: const FitBoundsOptions(inside: true),
          onPositionChanged: gameState.onMapPositionChanged,
          onTap: (_, point) async => _onMapPressed(
            context,
            point,
            bigScreen,
          ),
        ),
        children: [
          // TileLayer(
          //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // ),
          PolygonLayer(
            polygons: gameState.polygons,
            // ignore: avoid_redundant_argument_values
            polygonCulling:
                true, //!kDebugMode, // throws exceptions on hot reload
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
    bool isBigScreen,
  ) async {
    // find pressed country
    final gameState = ref.read(mapGameStateProvider);
    final point = Point(x: latLng.latitude, y: latLng.longitude);
    final polygon = gameState.polygons.firstWhereOrNull((polygon) {
      final points = polygon.points
          .map((e) => Point(x: e.latitude, y: e.longitude))
          .toList(growable: false);
      return Poly.isPointInPolygon(point, points);
    }) as CountryPolygon?;

    if (polygon == null) {
      debugPrint('No country pressed');
      return;
    }
    final state = polygon.state;
    debugPrint(polygon.state.country.name);

    // abort if guessed too much
    final attempts = state.tries;
    if (attempts >= gameState.maxTries) return;
    if (state.isFinished) return;

    gameState.countryMapSelection = polygon.state.country;

    // get guess if selection is null
    if (gameState.countryListSelection == null) {
      if (!isBigScreen) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CountryList(),
          ),
        );
      }
      // reload map to show selection on map
      gameState.reloadMapPolygons(reloadViews: true);
    }
    if (gameState.countryListSelection == null) return;

    // save attempt
    gameState.addGuess();

    // show end dialog if game is finished
    if (gameState.isFinished) {
      await showDialog(
        context: context,
        builder: (context) => EndDialog(
          correct: gameState.amountFinished,
          wrong: gameState.amountWrong,
          time: gameState.stopwatch.elapsed,
        ),
      );
    }
  }
}
