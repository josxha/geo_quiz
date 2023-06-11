import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geo_quiz/shared/common.dart';

final geoJsonProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final jsonStrings = await Future.wait([
    rootBundle.loadString('assets/geo-json/countries-res1.json'),
    rootBundle.loadString('assets/geo-json/countries-res2.json'),
    rootBundle.loadString('assets/geo-json/countries-res3.json'),
    rootBundle.loadString('assets/geo-json/countries-res4.json'),
  ]);
  return [
    jsonDecode(jsonStrings[0]),
    jsonDecode(jsonStrings[1]),
    jsonDecode(jsonStrings[2]),
    jsonDecode(jsonStrings[3]),
  ];
});
