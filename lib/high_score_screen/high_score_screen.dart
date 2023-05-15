import 'package:geo_quiz/shared/common.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.highScores),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Text('Your Scores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
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
