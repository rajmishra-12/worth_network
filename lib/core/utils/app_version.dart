
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callNumber(String number) async {
  final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

class AppVersion {
  static String? _cachedVersion;

  /// Fetch dynamic version from pubspec / native platform info
  static Future<String> getVersion() async {
    if (_cachedVersion != null) return _cachedVersion!;
    try {
      final info = await PackageInfo.fromPlatform();
      _cachedVersion = 'Version ${info.version}';
      return _cachedVersion!;
    } catch (_) {
      return 'Version 1.0.0';
    }
  }
}
