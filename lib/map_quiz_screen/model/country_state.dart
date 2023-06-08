import 'package:geo_quiz/map_quiz_screen/model/polygon_state.dart';
import 'package:geo_quiz/shared/common.dart';
import 'package:geo_quiz/shared/countries.dart';

class CountryState {
  final Country country;
  PolygonState polygonState = PolygonState.init;
  int tries = 0;
  bool answeredCorrect = false;
  bool isSelected = false;

  CountryState(this.country);

  Color toColor() {
    if (isSelected) return Colors.blueAccent;
    if (answeredCorrect) return Colors.lightGreen;
    if (answeredWrong) return Colors.redAccent;
    if (tries > 0) return Colors.amber;
    return Colors.grey;
  }

  bool get isFinished => answeredCorrect || answeredWrong;

  bool get answeredWrong => tries >= maxTries;

  int get maxTries => GetIt.I<PrefService>().maxTries;
}
