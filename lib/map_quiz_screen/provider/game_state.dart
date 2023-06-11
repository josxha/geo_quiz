import 'package:flutter_map/flutter_map.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_polygon.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_state.dart';
import 'package:geo_quiz/map_quiz_screen/provider/geo_json.dart';
import 'package:geo_quiz/map_quiz_screen/utils/geojson_parser.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/countries.dart';
import 'package:latlong2/latlong.dart';

final mapGameStateProvider = ChangeNotifierProvider.autoDispose<MapGameState>(
  (ref) {
    final geoJson = ref.watch(geoJsonProvider);
    return MapGameState(geoJson.value);
  },
);

class MapGameState with ChangeNotifier {
  final _prefService = GetIt.I<PrefService>();
  final stopwatch = Stopwatch();
  List<Map<String, dynamic>>? geoJson;
  late List<List<Polygon>> polygonResolutions;
  List<Polygon> _activeMapPolygons = [];
  List<Polygon> polygons = [];
  final _states = <String, CountryState>{};

  Country? _countryListSelection;
  Country? _countryMapSelection;
  final searchController = TextEditingController();
  String _listFilter = '';

  List<Country> _filteredCountries = [];

  double lastZoom = 2.5;

  MapGameState(this.geoJson) {
    if (geoJson != null) {
      for (final feature in geoJson!.first['features']) {
        final properties = feature['properties'];
        final code = properties['ISO_A3'];
        final name = properties['ADMIN'];
        _states[code] = CountryState(Country(code: code, name: name));
      }
      // store polygons
      polygonResolutions = geoJson!.map((json) {
        final geoJsonParser = GeoJsonParser(
          polygonCreationCallback: (points, holes, properties) =>
              _polygonCreationCallback(points, holes, properties),
        );
        geoJsonParser.parseGeoJson(json);
        return geoJsonParser.polygons;
      }).toList(growable: false);
      _activeMapPolygons = polygonResolutions.first; // lowest resolution
      reloadMapPolygons();
      resetListFilter();
      stopwatch.start();
    }
  }

  bool get isInitialized => geoJson != null;

  int get amountFinished =>
      _states.values.where((element) => element.isFinished).length;

  int get amountCorrect =>
      _states.values.where((element) => element.answeredCorrect).length;

  int get amountWrong =>
      _states.values.where((element) => element.answeredWrong).length;

  bool get isFinished => amountFinished == amountTotal;

  int get amountTotal => _states.values.length;

  double get progress => amountFinished / amountTotal;

  int get maxTries => _prefService.maxTries;

  CountryState getStateForCountryCode(String code) => _states[code]!;

  Country? get countryMapSelection => _countryMapSelection;

  set countryMapSelection(Country? value) {
    // deselect old map polygon
    if (_countryMapSelection != null) {
      _states[_countryMapSelection!.code]!.isSelected = false;
    }
    if (_countryMapSelection == value) {
      // deselect if same country clicked again
      _countryMapSelection = null;
      notifyListeners();
      return;
    }
    // set new polygon as selected
    if (value != null) {
      _states[value.code]!.isSelected = true;
    }
    _countryMapSelection = value;
    notifyListeners();
  }

  Country? get countryListSelection => _countryListSelection;

  set countryListSelection(Country? value) {
    if (_countryListSelection == value) {
      _countryListSelection = null;
    } else {
      _countryListSelection = value;
    }
    if (_countryMapSelection != null) {
      addGuess();
    }
    notifyListeners();
  }

  String get listFilter => _listFilter;

  bool get selectionIsCorrect => countryListSelection == countryMapSelection;

  set listFilter(String filter) {
    _listFilter = filter;
    final filterLower = filter.toLowerCase();
    _filteredCountries = _states.values
        .where((state) {
          if (state.isFinished) return false;
          return state.country.name.toLowerCase().contains(filterLower);
        })
        .map((e) => e.country)
        .toList(growable: false);
    _filteredCountries.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void resetListFilter() {
    searchController.clear();
    listFilter = '';
  }

  List<Country> get filteredCountries => _filteredCountries;

  void reloadMapPolygons({bool reloadViews = false}) {
    if (geoJson == null) {
      debugPrint('Do not reload Map, geoJson is null  ');
      return;
    }
    polygons = [];
    for (final polygon in _activeMapPolygons.cast<CountryPolygon>()) {
      polygons.add(
        _polygonCreationCallback(
          polygon.points,
          polygon.holePointsList,
          polygon.properties,
        ),
      );
    }
    if (reloadViews) notifyListeners();
  }

  Polygon _polygonCreationCallback(
    List<LatLng> points,
    List<List<LatLng>>? holePointsList,
    Map<String, dynamic> properties,
  ) {
    final countryCode = properties['ISO_A3'];
    return CountryPolygon(
      points: points,
      holePointsList: holePointsList,
      properties: properties,
      state: _states[countryCode]!,
      showLabel: _prefService.labelCountriesAfterFinished
          ? ShowLabel.ifFinished
          : ShowLabel.never,
    );
  }

  void addGuess() {
    final state = _states[_countryMapSelection!.code]!;
    state.tries++;
    if (selectionIsCorrect) {
      state.answeredCorrect = true;
    }

    // clear selection
    _countryListSelection = null;
    countryMapSelection = null; // sets the polygon selection too
    // update map
    reloadMapPolygons();
    // update country list
    //resetListFilter(); // calls notifyListeners
    notifyListeners();
  }

  void onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (position.zoom == null) return;
    final zoom = position.zoom!;
    if (zoom >= 9 && lastZoom < 9) {
      _activeMapPolygons = polygonResolutions[3];
      reloadMapPolygons(reloadViews: true);
    } else if (zoom >= 6.5 && (lastZoom < 6.5 || lastZoom > 9)) {
      _activeMapPolygons = polygonResolutions[2];
      reloadMapPolygons(reloadViews: true);
    } else if (zoom >= 4 && (lastZoom < 4 || lastZoom > 6.5)) {
      _activeMapPolygons = polygonResolutions[1];
      reloadMapPolygons(reloadViews: true);
    } else if (zoom <= 4 && lastZoom > 4) {
      _activeMapPolygons = polygonResolutions[0];
      reloadMapPolygons(reloadViews: true);
    }
    lastZoom = zoom;
  }
}
