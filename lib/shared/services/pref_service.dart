class PrefService {
  bool showTime = false;
  int maxTries = 3;
  bool labelCountriesAfterFinished = true;

  PrefService._();

  static Future<PrefService> createInstance() async {
    return PrefService._();
  }
}
