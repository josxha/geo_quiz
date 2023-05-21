import 'package:geo_quiz/game_screen/pause_dialog.dart';
import 'package:geo_quiz/shared/common.dart';

class GameScreen extends StatefulWidget {
  final Widget child;
  final double? progress;
  final int? errors;
  final Widget? floatingActionButton;
  final Stopwatch? stopwatch;

  const GameScreen({
    super.key,
    required this.child,
    this.progress,
    this.errors,
    this.floatingActionButton,
    this.stopwatch,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _prefService = GetIt.I<PrefService>();
  var _gamePaused = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (_prefService.showTime && widget.stopwatch != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(FontAwesomeIcons.clock),
                    const SizedBox(width: 8),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final duration = widget.stopwatch!.elapsed;
                        final min = duration.inMinutes;
                        final sec = (duration.inSeconds % 60)
                            .toString()
                            .padLeft(2, '0');
                        return Text('$min:$sec');
                      },
                    ),
                  ],
                ),
              if (widget.progress != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(FontAwesomeIcons.chartLine),
                    const SizedBox(width: 8),
                    Text('${(widget.progress! * 100).toStringAsFixed(2)} %'),
                  ],
                ),
              if (widget.errors != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(FontAwesomeIcons.xmark),
                    const SizedBox(width: 8),
                    Text(widget.errors!.toString()),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: widget.floatingActionButton,
        body: widget.child,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_gamePaused) return true;

    _gamePaused = true;
    widget.stopwatch?.stop();

    final continueGame = await showDialog(
          context: context,
          builder: (context) => const PauseDialog(),
        ) as bool? ??
        true;
    // debugPrint('continue game: $continueGame');
    if (continueGame) {
      _gamePaused = false;
      widget.stopwatch?.start();
      return false;
    }
    return true;
  }
}
