import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CountryPolygon extends Polygon {
  final Map<String, dynamic> properties;
  final CountryState state;

  CountryPolygon({
    required super.points,
    required super.holePointsList,
    required this.state,
    required this.properties,
  }) : super(
          color: state.toColor(),
          borderStrokeWidth: 0.5,
          borderColor: Colors.black,
          isFilled: true,
          label: state.isFinished() ? properties['name'] : null,
        );
}

enum CountryState {
  unset,
  tried,
  wrong,
  correct;

  Color toColor() => switch (this) {
        unset => Colors.grey,
        tried => Colors.amber,
        wrong => Colors.redAccent,
        correct => Colors.lightGreen,
      };

  bool isFinished() => [wrong, correct].contains(this);
}
