import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../Ads/HouseAd/house_ad_manager.dart';
import '../../Ads/HouseAd/house_banner_ad.dart';
import '../../AdsWidget/AppLovin/Banner/applovin_banner.dart';
import '../../AdsWidget/Google/Banner/google_banner.dart';
import '../../MainJson/main_json.dart';

class BannerAd extends HookWidget {
  final BuildContext parentContext;

  const BannerAd({required this.parentContext, super.key});

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.read<MainJson>();
    final bannerWidget = useState<Widget>(const SizedBox(height: 0, width: 0));

    showHouseAd() {
      final v = mainJson.data?['version_config']?[mainJson.version];
      if ((v?['globalConfig']?['globalAdFlag'] ?? true) == false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final houseAds = mainJson.data?['house_ads'];
      if (houseAds == null || (houseAds['banner_enabled'] ?? true) == false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final apps = houseAds['apps'] as List? ?? [];
      final ad = HouseAdManager.getNextBanner(apps);
      if (ad == null) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      bannerWidget.value = HouseBannerAd(ad: ad);
    }

    showAd() {
      if (!mainJson.isAdsOn) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      final v = mainJson.data?['version_config']?[mainJson.version];
      final route = ModalRoute.of(parentContext)?.settings.name;
      final screenConfig = v?['screens']?[route];

      if ((v?['globalConfig']?['globalAdFlag'] ?? true) == false ||
          (v?['globalConfig']?['globalBanner'] ?? true) == false ||
          screenConfig == null ||
          (screenConfig['localAdFlag'] ?? true) == false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      switch (screenConfig['banner']) {
        case 0:
          bannerWidget.value = GoogleBanner(onFailed: showHouseAd);
          break;
        case 1:
          bannerWidget.value = ApplovinBanner(onFailed: showHouseAd);
          break;
        default:
          bannerWidget.value = const SizedBox(height: 0, width: 0);
          break;
      }
    }

    useEffect(() {
      showAd();
      return () {};
    }, []);
    return bannerWidget.value;
  }
}
