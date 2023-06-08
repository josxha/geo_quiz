import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_polygon.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_state.dart';
import 'package:geo_quiz/map_quiz_screen/provider/geo_json.dart';
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
  Map<String, dynamic>? geoJson;
  late final GeoJsonParser _geoJsonParser;
  late List<Polygon> polygons;
  final _states = <String, CountryState>{};

  Country? _countryListSelection;
  Country? _countryMapSelection;
  final searchController = TextEditingController();
  String _listFilter = '';

  List<Country> _filteredCountries = [];

  MapGameState(this.geoJson) {
    _geoJsonParser = GeoJsonParser(
      polygonCreationCallback: (points, holes, properties) =>
          _polygonCreationCallback(points, holes, properties),
    );
    if (geoJson != null) {
      for (final feature in geoJson!['features']) {
        final properties = feature['properties'];
        final code = properties['iso_a2'];
        final name = properties['name'];
        _states[code] = CountryState(Country(code: code, name: name));
      }
      _geoJsonParser.parseGeoJson(geoJson!);
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
    // set new polygon as selected
    if (value != null) {
      _states[value.code]!.isSelected = true;
    }
    _countryMapSelection = value;
    notifyListeners();
  }

  Country? get countryListSelection => _countryListSelection;

  set countryListSelection(Country? value) {
    _countryListSelection = value;
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
    for (final polygon in _geoJsonParser.polygons.cast<CountryPolygon>()) {
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
    final countryCode = properties['iso_a2'];
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
    resetListFilter(); // calls notifyListeners
    //notifyListeners();
  }
}
