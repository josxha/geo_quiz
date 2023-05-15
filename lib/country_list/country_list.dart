import 'package:geo_quiz/shared/common.dart';

class CountryList extends StatefulWidget {
  final List<String> countries;

  const CountryList(this.countries, {super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  final _controller = TextEditingController();
  late List<String> filtered;

  @override
  void initState() {
    filtered = widget.countries;
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
              itemBuilder: (context, index) => ListTile(
                title: Text(filtered[index]),
                onTap: () => Navigator.of(context).pop(filtered[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _search(String value) {
    if (value.isEmpty) {
      setState(() {
        filtered = widget.countries;
      });
      return;
    }
    debugPrint(value);
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
      _controller.text = '';
      filtered = widget.countries;
    });
  }
}
