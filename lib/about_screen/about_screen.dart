import 'package:flutter/material.dart';
import 'package:geo_quiz/shared/services/app_info_service.dart';
import 'package:get_it/get_it.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = GetIt.I<AppInfoService>();

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Geo Quiz',
              applicationVersion: appInfo.appVersion,
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
  }
}
