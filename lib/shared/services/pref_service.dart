class PrefService {
  bool showTime = true;
  int maxTries = 3;
  bool labelCountriesAfterFinished = true;

  PrefService._();

  static Future<PrefService> createInstance() async {
    return PrefService._();
  }
}
