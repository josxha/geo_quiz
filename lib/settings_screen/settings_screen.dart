import 'package:flutter/material.dart';
import 'package:geo_quiz/shared/services/pref_service.dart';
import 'package:get_it/get_it.dart';

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
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Zeit anzeigen'),
            value: _prefService.showTime,
            onChanged: (value) => setState(() {
              _prefService.showTime = value;
            }),
          ),
        ],
      ),
    );
  }
}
