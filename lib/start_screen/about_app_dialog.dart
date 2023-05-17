import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/services/app_info_service.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = GetIt.I<AppInfoService>();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.aboutTheApp),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('GitHub'),
              onTap: () async =>
                  'https://github.com/josxha/geo_quiz'.launchUrl(),
              leading: const FaIcon(FontAwesomeIcons.github),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.usedLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'GeoQuiz',
                applicationVersion: appInfo.appVersion,
              ),
              leading: const FaIcon(FontAwesomeIcons.fileContract),
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
