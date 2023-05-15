import 'package:geo_quiz/shared/common.dart';

class CountryList extends StatefulWidget {
  final CountryListArgs args;

  const CountryList(this.args, {super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  final _controller = TextEditingController();
  late List<String> filtered;

  List<String> get countries => widget.args.countries;

  String? get selection => widget.args.selection;

  @override
  void initState() {
    filtered = countries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.countryNames)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SearchBar(
              controller: _controller,
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.cancel),
                ),
              ],
              hintText: AppLocalizations.of(context)!.searchHint,
              onChanged: _search,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final country = filtered[index];
                return ListTile(
                  title: Text(country),
                  selected: country == selection,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () => Navigator.of(context).pop(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search(String value) {
    if (value.isEmpty) {
      setState(() {
        filtered = countries;
      });
      return;
    }
    // debugPrint('Search: $value');
    setState(() {
      filtered = countries
          .where(
            (country) => country.toLowerCase().contains(value.toLowerCase()),
          )
          .toList(growable: false);
    });
  }

  void _clearSearch() {
    setState(() {
      _controller.text = '';
      filtered = countries;
    });
  }
}

@immutable
class CountryListArgs {
  final List<String> countries;
  final String? selection;

  const CountryListArgs(this.countries, this.selection);
}
