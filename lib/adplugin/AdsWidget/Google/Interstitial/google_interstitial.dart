import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';
import '../../../Methods/google_init.dart';

class GoogleInterstitial {
  InterstitialAd? interstitialAd;

  loadAd({
    required BuildContext context,
    required Function() onLoaded,
    required Function() onComplete,
    required Function() onFailed,
  }) async {
    // Wait for MobileAds.initialize() to complete before loading.
    // Allows splash screen ads to work with non-blocking init.
    await GoogleInit.ready;
    MainJson mainJson = context.read<MainJson>();
    InterstitialAd.load(
      adUnitId: !mainJson.isTestOn
          ? '${mainJson.data!['adIds']['google']['fullScreen']}'
          : Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              onFailed();
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              onComplete();

              ad.dispose();
            },
            onAdClicked: (ad) {},
          );

          interstitialAd = ad;
          onLoaded();
          interstitialAd!.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          onFailed();
        },
      ),
    );
  }
}
