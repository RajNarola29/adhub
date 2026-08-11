import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';
import '../../../Methods/google_init.dart';

class GoogleNative extends HookWidget {
  final VoidCallback onFailed;
  final EdgeInsets margin;

  const GoogleNative({
    required this.onFailed,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final nativeAd = useState<NativeAd?>(null);
    final nativeAdIsLoaded = useState<bool>(false);
    final nativeWidget = useState<AdWidget?>(null);

    MainJson mainJson = context.read<MainJson>();

    loadAd() async {
      await GoogleInit.ready;
      nativeAd.value = NativeAd(
        adUnitId: !mainJson.isTestOn
            ? '${mainJson.data!['ad_config']['admob_native']}'
            : Platform.isIOS
            ? 'ca-app-pub-3940256099942544/3986624511'
            : 'ca-app-pub-3940256099942544/2247696110',
        factoryId: 'adFactoryExample',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            onFailed();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
      );
      // Assigned before `load()` so `nativeWidget.value` is never null by
      // the time `onAdLoaded` can fire and flip `nativeAdIsLoaded`.
      nativeWidget.value = AdWidget(ad: nativeAd.value!);
      nativeAd.value!.load();
    }

    useEffect(() {
      loadAd();
      return () {
        nativeAd.value?.dispose();
      };
    }, []);
    return nativeAdIsLoaded.value
        ? Container(
            margin: margin,
            constraints: const BoxConstraints(minHeight: 270, maxHeight: 402),
            decoration: BoxDecoration(
              color: mainJson.nativeColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: mainJson.nativeBorderColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            width: double.infinity,
            child: Stack(
              children: [
                nativeWidget.value!,
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    color: const Color(0xFFFFCC00),
                    child: const Text(
                      'Ad',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
