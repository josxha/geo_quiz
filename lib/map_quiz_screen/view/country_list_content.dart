import 'package:geo_quiz/map_quiz_screen/provider/game_state.dart';
import 'package:geo_quiz/shared/common.dart';

class CountryListContent extends ConsumerStatefulWidget {
  final VoidCallback? onSelected;

  const CountryListContent({
    super.key,
    this.onSelected,
  });

  @override
  ConsumerState<CountryListContent> createState() => _CountryListContentState();
}

class _CountryListContentState extends ConsumerState<CountryListContent> {
  late final _searchController;
  final _scrollController = ScrollController();
  final _searchBarFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _searchBarFocus.requestFocus();
    });
    final gameState = ref.read(mapGameStateProvider);
    _searchController = TextEditingController(text: gameState.listFilter);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(mapGameStateProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            focusNode: _searchBarFocus,
            controller: _searchController,
            leading: const FaIcon(FontAwesomeIcons.magnifyingGlass),
            trailing: [
              IconButton(
                onPressed: gameState.resetListFilter,
                icon: const FaIcon(FontAwesomeIcons.ban),
              ),
            ],
            hintText: AppLocalizations.of(context)!.searchHint,
            onChanged: (value) => gameState.listFilter = value,
          ),
        ),
        Expanded(
          child: Scrollbar(
            trackVisibility: true,
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: gameState.filteredCountries.length,
              itemBuilder: (context, index) {
                final country = gameState.filteredCountries[index];
                return ListTile(
                  title: Text(country.name),
                  selected: country == gameState.countryListSelection,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () {
                    gameState.countryListSelection = country;
                    widget.onSelected?.call();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
