import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  final PackageInfo _packageInfo;

  AppInfoService._(this._packageInfo);

  static Future<AppInfoService> createInstance() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppInfoService._(packageInfo);
  }

  String get appVersion => _packageInfo.version;
}
