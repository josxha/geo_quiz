import 'package:geo_quiz/shared/common.dart';

class MapQuizSettingsScreen extends StatefulWidget {
  const MapQuizSettingsScreen({super.key});

  @override
  State<MapQuizSettingsScreen> createState() => _MapQuizSettingsScreenState();
}

class _MapQuizSettingsScreenState extends State<MapQuizSettingsScreen> {
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
            value: _prefService.labelCountriesAfterFinished,
            onChanged: (value) => setState(() {
              _prefService.labelCountriesAfterFinished = value;
            }),
          ),
        ],
      ),
      persistentFooterButtons: [
        MaterialButton(
          color: Colors.lightGreen,
          onPressed: () => context.pushNamed(Routes.mapQuiz),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Spiel starten'),
          ),
        ),
      ],
    );
  }
}
