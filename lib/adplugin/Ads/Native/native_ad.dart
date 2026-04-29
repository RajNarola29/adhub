// 🐦 Flutter imports:
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../AdsWidget/Google/Native/google_native.dart';
import '../../MainJson/main_json.dart';

class NativeAd extends HookWidget {
  final BuildContext parentContext;

  const NativeAd({required this.parentContext, super.key});

  @override
  Widget build(BuildContext context) {
    final nativeWidget = useState<Widget>(const SizedBox(height: 0, width: 0));

    showAd() {
      MainJson mainJson = context.read<MainJson>();
      if (!mainJson.isAdsOn) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }
      final v = mainJson.data?['version_config']?[mainJson.version];
      final route = ModalRoute.of(parentContext)?.settings.name;
      final screenConfig = v?['screens']?[route];

      if ((v?['globalConfig']?['globalAdFlag'] ?? false) == false ||
          (v?['globalConfig']?['globalNative'] ?? false) == false ||
          screenConfig == null ||
          (screenConfig['localAdFlag'] ?? false) == false) {
        nativeWidget.value = const SizedBox(height: 0, width: 0);
        return;
      }

      switch (screenConfig['native']) {
        case 0:
          nativeWidget.value = const GoogleNative();
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
