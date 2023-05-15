import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

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
              state.isFinished() ? properties['name'] : null,
            ShowLabel.always => properties['name'],
          },
        );
}

enum CountryState {
  unset,
  selected,
  tried,
  wrong,
  correct;

  Color toColor() => switch (this) {
        unset => Colors.grey,
        selected => Colors.blueAccent,
        tried => Colors.amber,
        wrong => Colors.redAccent,
        correct => Colors.lightGreen,
      };

  bool isFinished() => [wrong, correct].contains(this);
}

enum ShowLabel { never, ifFinished, always }
