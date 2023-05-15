import 'package:geo_quiz/shared/common.dart';

class CountryListContent extends StatefulWidget {
  final List<String> countries;
  final String? selection;
  final void Function(String) onSelected;

  const CountryListContent({
    super.key,
    required this.onSelected,
    required this.countries,
    this.selection,
  });

  @override
  State<CountryListContent> createState() => _CountryListContentState();
}

class _CountryListContentState extends State<CountryListContent> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchBarFocus = FocusNode();

  late List<String> filtered;

  @override
  void initState() {
    filtered = widget.countries;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _searchBarFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _clearSearch,
                icon: const FaIcon(FontAwesomeIcons.ban),
              ),
            ],
            hintText: AppLocalizations.of(context)!.searchHint,
            onChanged: _search,
          ),
        ),
        Expanded(
          child: Scrollbar(
            trackVisibility: true,
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final country = filtered[index];
                return ListTile(
                  title: Text(country),
                  selected: country == widget.selection,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () => widget.onSelected(country),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _search(String value) {
    if (value.isEmpty) {
      setState(() {
        filtered = widget.countries;
      });
      return;
    }
    // debugPrint('Search: $value');
    setState(() {
      filtered = widget.countries
          .where(
            (country) => country.toLowerCase().contains(value.toLowerCase()),
          )
          .toList(growable: false);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.text = '';
      filtered = widget.countries;
    });
  }
}
