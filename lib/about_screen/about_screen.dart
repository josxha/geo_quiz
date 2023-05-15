import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/app_info_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = GetIt.I<AppInfoService>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aboutTheApp)),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.usedLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'GeoQuiz',
              applicationVersion: appInfo.appVersion,
            ),
            trailing: const FaIcon(FontAwesomeIcons.arrowRight),
          ),
        ],
      ),
    );
  }
}
