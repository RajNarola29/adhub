import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';

class GoogleNative extends HookWidget {
  const GoogleNative({super.key});

  @override
  Widget build(BuildContext context) {
    final nativeAd = useState<NativeAd?>(null);
    final nativeAdIsLoaded = useState<bool>(false);
    final nativeWidget = useState<AdWidget?>(null);

    MainJson mainJson = context.read<MainJson>();

    loadAd() {
      nativeAd.value = NativeAd(
        adUnitId: !mainJson.isTestOn
            ? '${mainJson.data!['adIds']['google']['native']}'
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
      nativeAd.value!.load();
      nativeWidget.value = AdWidget(ad: nativeAd.value!);
    }

    useEffect(() {
      loadAd();
      return () {};
    }, []);
    return nativeAdIsLoaded.value
        ? Container(
            margin: const EdgeInsets.all(10.0),
            constraints: const BoxConstraints(minHeight: 270, maxHeight: 402),
            decoration: BoxDecoration(color: mainJson.nativeColor),
            alignment: Alignment.center,
            width: double.infinity,
            child: nativeWidget.value,
          )
        : const SizedBox.shrink();
  }
}
