import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geo_quiz/shared/common.dart';

final geoJsonProvider = FutureProvider<GeoJsonTuple>((ref) async {
  final jsonStrings = await Future.wait([
    rootBundle.loadString('assets/geo-json/countries-big.json'),
    rootBundle.loadString('assets/geo-json/countries-mid.json'),
    rootBundle.loadString('assets/geo-json/countries-small.json'),
  ]);
  final Map<String, dynamic> geoJsonBig = jsonDecode(jsonStrings[0]);
  final Map<String, dynamic> geoJsonMid = jsonDecode(jsonStrings[1]);
  final Map<String, dynamic> geoJsonSmall = jsonDecode(jsonStrings[2]);
  return (geoJsonBig, geoJsonMid, geoJsonSmall);
});

typedef GeoJsonTuple = (
  Map<String, dynamic>,
  Map<String, dynamic>,
  Map<String, dynamic>,
);
