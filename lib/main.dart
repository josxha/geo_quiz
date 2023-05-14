import 'package:flutter/material.dart';
import 'package:geo_quiz/routes.dart';
import 'package:geo_quiz/theme.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  // ignore: unreachable_from_main
  static NavigatorState get navigator => MyApp._navigatorKey.currentState!;

  // ignore: unreachable_from_main
  static BuildContext get context => MyApp._navigatorKey.currentContext!;

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp._navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Geo Quiz',
      theme: appTheme,
      onGenerateRoute: (settings) => Routes.generateRoute(settings),
      initialRoute: Routes.start.name,
    );
  }
}
