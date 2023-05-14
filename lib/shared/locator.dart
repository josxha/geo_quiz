import 'package:geo_quiz/shared/services/app_info_service.dart';
import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:geo_quiz/shared/services/pref_service.dart';
import 'package:get_it/get_it.dart';

Future<void> setupLocator() async {
  GetIt.I.registerSingletonAsync<PrefService>(
    () => PrefService.createInstance(),
  );
  GetIt.I.registerSingletonAsync<AppInfoService>(
    () => AppInfoService.createInstance(),
  );
  GetIt.I.registerLazySingletonAsync<GeoJsonService>(
    () => GeoJsonService.createInstance(),
  );

  await GetIt.I.allReady();
}
