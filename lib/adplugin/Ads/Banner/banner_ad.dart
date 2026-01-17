import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

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

      if ((mainJson.data![mainJson.version]['globalConfig']['globalAdFlag'] ??
              false) ==
          false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      if ((mainJson.data![mainJson.version]['globalConfig']['globalBanner'] ??
              false) ==
          false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      if ((mainJson.data![mainJson.version]['screens'][ModalRoute.of(
                parentContext,
              )?.settings.name]['localAdFlag'] ??
              false) ==
          false) {
        bannerWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      switch (mainJson.data![mainJson.version]['screens'][ModalRoute.of(
        parentContext,
      )?.settings.name]['banner']) {
        case 0:
          bannerWidget.value = const GoogleBanner();
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
