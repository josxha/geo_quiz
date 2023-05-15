import 'package:geo_quiz/shared/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefService = GetIt.I<PrefService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.showTime),
            value: _prefService.showTime,
            onChanged: (value) => setState(() {
              _prefService.showTime = value;
            }),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.labelCountries),
            value: _prefService.labelCountriesAfterGuessed,
            onChanged: (value) => setState(() {
              _prefService.labelCountriesAfterGuessed = value;
            }),
          ),
        ],
      ),
    );
  }
}
