import 'package:flutter/material.dart';

class CountryList extends StatefulWidget {
  final List<String> countries;

  const CountryList(this.countries, {super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ländernamen')),
      body: ListView.builder(
        itemCount: widget.countries.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(widget.countries[index]),
          onTap: () => Navigator.of(context).pop(widget.countries[index]),
        ),
      ),
    );
  }
}
