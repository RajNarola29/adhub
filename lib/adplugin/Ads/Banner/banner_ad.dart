import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

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

    showAd() {
      if (!mainJson.isAdsOn) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      final v = mainJson.data?['version_config']?[mainJson.version];
      final route = ModalRoute.of(parentContext)?.settings.name;
      final screenConfig = v?['screens']?[route];

      if ((v?['globalConfig']?['globalAdFlag'] ?? false) == false ||
          (v?['globalConfig']?['globalBanner'] ?? false) == false ||
          screenConfig == null ||
          (screenConfig['localAdFlag'] ?? false) == false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      switch (screenConfig['banner']) {
        case 0:
          bannerWidget.value = const GoogleBanner();
          break;
        case 1:
          bannerWidget.value = const ApplovinBanner();
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
