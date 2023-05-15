import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/app_info_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
            title: const Text('GitHub'),
            onTap: () async {
              final uri = Uri.parse('https://github.com/josxha/geo_quiz');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            leading: const FaIcon(FontAwesomeIcons.github),
            trailing: const FaIcon(FontAwesomeIcons.arrowRight),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.usedLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'GeoQuiz',
              applicationVersion: appInfo.appVersion,
            ),
            leading: const FaIcon(FontAwesomeIcons.fileContract),
            trailing: const FaIcon(FontAwesomeIcons.arrowRight),
          ),
        ],
      ),
    );
  }
}
