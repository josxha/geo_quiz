import 'package:geo_quiz/country_list/country_list_content.dart';
import 'package:geo_quiz/shared/common.dart';

class CountryList extends StatefulWidget {
  final CountryListArgs args;

  const CountryList(this.args, {super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.countryNames)),
      body: CountryListContent(
        countries: widget.args.countries,
        selection: widget.args.selection,
        onSelected: (country) {
          Navigator.of(context).pop(country);
        },
      ),
    );
  }
}

@immutable
class CountryListArgs {
  final List<String> countries;
  final String? selection;

  const CountryListArgs(this.countries, this.selection);
}
