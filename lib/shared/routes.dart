import 'package:geo_quiz/flag_screen/flag_quiz_screen.dart';
import 'package:geo_quiz/high_score_screen/high_score_screen.dart';
import 'package:geo_quiz/invalid_route_screen.dart';
import 'package:geo_quiz/map_quiz_screen/map_quiz_screen.dart';
import 'package:geo_quiz/settings_screen/settings_screen.dart';
import 'package:geo_quiz/start_screen/start_screen.dart';
import 'package:go_router/go_router.dart';

abstract class Routes {
  static const start = '/';
  static const mapQuiz = 'mapQuiz';
  static const flagQuiz = 'flagQuiz';
  static const highScores = 'highScores';
  static const settings = 'settings';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: start,
        name: start,
        builder: (context, state) => const StartScreen(),
        routes: [
          GoRoute(
            path: mapQuiz,
            name: mapQuiz,
            builder: (context, state) => const MapQuizScreen(),
          ),
          GoRoute(
            path: flagQuiz,
            name: flagQuiz,
            builder: (context, state) => const FlagQuizScreen(),
          ),
          GoRoute(
            path: highScores,
            name: highScores,
            builder: (context, state) => const HighScoreScreen(),
          ),
          GoRoute(
            path: settings,
            name: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => InvalidRouteScreen(state.location),
    initialLocation: start,
  );
}
