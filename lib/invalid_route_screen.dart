import 'package:flutter/material.dart';

class InvalidRouteScreen extends StatelessWidget {
  final String? routeName;

  const InvalidRouteScreen(this.routeName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Die angefragte Route existiert nicht.\n'
            '$routeName'),
      ),
    );
  }
}
