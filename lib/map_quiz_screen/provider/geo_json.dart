import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geo_quiz/shared/common.dart';

final geoJsonProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/countries.json');
  final geoJson = jsonDecode(jsonString);
  return geoJson;
});
