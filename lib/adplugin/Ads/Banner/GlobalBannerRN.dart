// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../AdsWidget/Google/Banner/google_banner.dart';
import '../../MainJson/main_json.dart';

class GlobalBannerRN extends HookWidget {
  final BuildContext parentContext;

  const GlobalBannerRN({required this.parentContext, super.key});

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.read<MainJson>();
    final bannerWidget = useState<Widget>(const SizedBox(height: 0, width: 0));

    showAd() {
      if (mainJson.data == null || mainJson.data == {}) {
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

      bannerWidget.value = const GoogleBanner();
    }

    useEffect(() {
      showAd();
      return () {};
    }, []);
    return bannerWidget.value;
  }
}
