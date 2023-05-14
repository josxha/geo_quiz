import 'dart:convert';

import 'package:flutter/services.dart';

class GeoJsonService {
  final Map<String, dynamic> json;

  GeoJsonService._(this.json);

  static Future<GeoJsonService> createInstance() async {
    final jsonString = await rootBundle.loadString('assets/countries.json');
    final geoJson = jsonDecode(jsonString);
    return GeoJsonService._(geoJson);
  }
}
