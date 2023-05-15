import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geo_quiz/shared/locator.dart';
import 'package:geo_quiz/shared/routes.dart';
import 'package:geo_quiz/shared/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
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
      title: 'GeoQuiz',
      theme: appTheme,
      onGenerateRoute: (settings) => Routes.generateRoute(settings),
      initialRoute: Routes.start.name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
