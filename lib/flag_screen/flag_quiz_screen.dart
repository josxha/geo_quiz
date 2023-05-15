import 'package:flutter_svg/flutter_svg.dart';
import 'package:geo_quiz/shared/common.dart';

class FlagQuizScreen extends StatelessWidget {
  final code = 'de';

  const FlagQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.flags)),
      body: Center(
        child: SvgPicture.asset('assets/flags/$code.svg'),
      ),
    );
  }
}
