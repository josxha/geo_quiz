import 'package:geo_quiz/game_screen/game_screen.dart';
import 'package:geo_quiz/map_quiz_screen/provider/game_state.dart';
import 'package:geo_quiz/map_quiz_screen/view/country_list.dart';
import 'package:geo_quiz/map_quiz_screen/view/country_list_content.dart';
import 'package:geo_quiz/map_quiz_screen/view/country_selection_text.dart';
import 'package:geo_quiz/map_quiz_screen/view/map_widget.dart';
import 'package:geo_quiz/shared/common.dart';

class MapQuizScreen extends ConsumerStatefulWidget {
  const MapQuizScreen({super.key});

  @override
  ConsumerState<MapQuizScreen> createState() => MapQuizScreenState();
}

class MapQuizScreenState extends ConsumerState<MapQuizScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(mapGameStateProvider);
    final size = MediaQuery.of(context).size;
    final bigScreen = size.width > 900;

    if (!gameState.isInitialized) {
      return GameScreen(
        stopwatch: gameState.stopwatch,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return GameScreen(
      stopwatch: gameState.stopwatch,
      progress: gameState.progress,
      floatingActionButton: bigScreen
          ? null
          : FloatingActionButton.extended(
              label: Text(AppLocalizations.of(context)!.countryNames),
              icon: const FaIcon(FontAwesomeIcons.flag),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CountryList(),
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                if (!bigScreen && gameState.countryListSelection != null)
                  CountrySelectionText(gameState.countryListSelection!.name),
                const Expanded(child: MapWidget()),
              ],
            ),
          ),
          if (bigScreen)
            const SizedBox(width: 300, child: CountryListContent()),
        ],
      ),
    );
  }
}
