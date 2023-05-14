import 'package:geo_quiz/shared/services/geojson_service.dart';
import 'package:get_it/get_it.dart';

Future<void> setupLocator() async {
  GetIt.I.registerLazySingletonAsync<GeoJsonService>(
        () => GeoJsonService.createInstance(),
  );

  await GetIt.I.allReady();
}
