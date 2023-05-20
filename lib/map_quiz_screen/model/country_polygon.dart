import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_quiz/map_quiz_screen/model/country_state.dart';

class CountryPolygon extends Polygon {
  final Map<String, dynamic> properties;
  final CountryState state;
  final ShowLabel showLabel;

  CountryPolygon({
    required super.points,
    required super.holePointsList,
    required this.state,
    required this.properties,
    this.showLabel = ShowLabel.always,
  }) : super(
          color: state.toColor(),
          borderStrokeWidth: 0.5,
          borderColor: Colors.black,
          isFilled: true,
          label: switch (showLabel) {
            ShowLabel.never => null,
            ShowLabel.ifFinished =>
              state.isFinished ? properties['name'] : null,
            ShowLabel.always => properties['name'],
          },
        );
}

enum ShowLabel {
  never,
  ifFinished,
  always;
}
