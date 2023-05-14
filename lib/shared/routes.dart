import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geo_quiz/invalid_route_screen.dart';
import 'package:geo_quiz/main.dart';
import 'package:geo_quiz/quiz_screen/quiz_screen.dart';
import 'package:geo_quiz/settings_screen/settings_screen.dart';
import 'package:geo_quiz/start_screen/start_screen.dart';

enum Routes {
  start('/'),
  quiz('/quiz'),
  settings('/settings');

  final String name;

  const Routes(this.name);

  Future<Object?> pushReplacement([
    NavigatorState? navigator,
    Object? arguments,
  ]) {
    final navi = navigator ?? MyApp.navigator;
    return navi.popAndPushNamed(name, arguments: arguments);
  }

  Future<Object?> popAndPush([
    NavigatorState? navigator,
    Object? arguments,
  ]) async {
    final navi = navigator ?? MyApp.navigator;
    return navi.popAndPushNamed(name, arguments: arguments);
  }

  Future<Object?> push([
    NavigatorState? navigator,
    Object? arguments,
  ]) async {
    final navi = navigator ?? MyApp.navigator;
    return navi.pushNamed(name, arguments: arguments);
  }

  /// used by flutter to generate routes
  static Route<dynamic> generateRoute(
    RouteSettings? settings,
  ) {
    return MaterialPageRoute(
      builder: (context) => _getView(settings?.name, settings?.arguments),
      settings: settings,
    );
  }

  static Routes? _parseRouteName(String? routeName) {
    return Routes.values
        .firstWhereOrNull((element) => element.name == routeName);
  }

  static Widget _getView(String? name, Object? args) {
    final route = _parseRouteName(name);
    switch (route) {
      case Routes.start:
        return const StartScreen();
      case Routes.quiz:
        return const QuizScreen();
      case Routes.settings:
        return const SettingsScreen();
      case null:
        return InvalidRouteScreen(name);
    }
  }
}
