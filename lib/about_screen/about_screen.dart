import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(children: [
        ListTile(
          title: const Text('Licenses'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Geo Quiz',
            applicationVersion: '1.0.0',
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ]),
    );
  }
}
