import 'dart:io' show Platform;

class HouseAdManager {
  static int _bannerIndex = 0;
  static int _nativeIndex = 0;

  static List<Map> _filterByPlatform(List apps) {
    final platform = Platform.isIOS ? 'ios' : 'android';
    return apps.whereType<Map>()
        .where((app) =>
            '${app['platform']}' == platform &&
            (app['enabled'] ?? true) == true)
        .toList();
  }

  static Map? getNextBanner(List apps) {
    final filtered = _filterByPlatform(apps);
    if (filtered.isEmpty) return null;
    final ad = filtered[_bannerIndex % filtered.length];
    _bannerIndex = (_bannerIndex + 1) % filtered.length;
    return ad;
  }

  static Map? getNextNative(List apps) {
    final filtered = _filterByPlatform(apps);
    if (filtered.isEmpty) return null;
    final ad = filtered[_nativeIndex % filtered.length];
    _nativeIndex = (_nativeIndex + 1) % filtered.length;
    return ad;
  }
}
