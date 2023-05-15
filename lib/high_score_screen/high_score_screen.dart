import 'package:geo_quiz/shared/common.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.highScores),
        bottom: const TabBar(
          tabs: [
            Text('test'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text((index + 1).toString()),
                title: Text('Rank $index'),
              );
            },
          )
        ],
      ),
    );
  }
}
