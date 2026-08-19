import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../Ads/HouseAd/house_ad_manager.dart';
import '../../Ads/HouseAd/house_native_ad.dart';
import '../../AdsWidget/AppLovin/Native/applovin_native.dart';
import '../../AdsWidget/Google/Native/google_native.dart';
import '../../MainJson/main_json.dart';

class NativeAd extends HookWidget {
  final BuildContext parentContext;

  /// Overrides the global [MainJson.nativeMargin] set via [Adhub] for this
  /// specific ad slot. Leave null to use the app-wide default.
  final EdgeInsets? margin;

  const NativeAd({required this.parentContext, this.margin, super.key});

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.read<MainJson>();
    final nativeWidget = useState<Widget>(const SizedBox(height: 0, width: 0));

    showHouseAd() {
      final v = mainJson.data?['version_config']?[mainJson.version];
      if ((v?['globalConfig']?['globalAdFlag'] ?? true) == false) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final houseAds = mainJson.data?['house_ads'];
      if (houseAds == null || (houseAds['native_enabled'] ?? true) == false) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final apps = houseAds['apps'] as List? ?? [];
      final ad = HouseAdManager.getNextNative(apps);
      if (ad == null) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      nativeWidget.value = HouseNativeAd(ad: ad, margin: margin ?? mainJson.nativeMargin);
    }

    showAd() {
      if (!mainJson.isAdsOn) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final v = mainJson.data?['version_config']?[mainJson.version];
      final route = ModalRoute.of(parentContext)?.settings.name;
      final screenConfig = v?['screens']?[route];

      if ((v?['globalConfig']?['globalAdFlag'] ?? true) == false ||
          (v?['globalConfig']?['globalNative'] ?? true) == false ||
          screenConfig == null ||
          (screenConfig['localAdFlag'] ?? true) == false) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      switch (screenConfig['native']) {
        case 0:
          nativeWidget.value = GoogleNative(
            onFailed: showHouseAd,
            margin: margin ?? mainJson.nativeMargin,
          );
          break;
        case 1:
          nativeWidget.value = ApplovinNative(
            onFailed: showHouseAd,
            margin: margin ?? mainJson.nativeMargin,
          );
          break;
        default:
          nativeWidget.value = const SizedBox(height: 0, width: 0);
          break;
      }
    }

    useEffect(() {
      showAd();
      return () {};
    }, []);
    return nativeWidget.value;
  }
}
