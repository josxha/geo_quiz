import 'package:url_launcher/url_launcher.dart' as url_launcher;

extension StringExt on String {
  Future<bool> launchUrl() async {
    final uri = Uri.tryParse(this);
    if (uri == null) return false;
    if (!await url_launcher.canLaunchUrl(uri)) return false;
    return url_launcher.launchUrl(uri);
  }
}
