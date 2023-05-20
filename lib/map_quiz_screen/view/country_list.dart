import 'package:geo_quiz/map_quiz_screen/view/country_list_content.dart';
import 'package:geo_quiz/shared/common.dart';

class CountryList extends StatelessWidget {
  const CountryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.countryNames)),
      body: CountryListContent(
        onSelected: () => context.pop(),
      ),
    );
  }
}
