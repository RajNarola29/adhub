import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../AdLoader/ad_loader_provider.dart';
import '../../../MainJson/main_json.dart';

class GoogleRewarded {
  RewardedAd? _rewardedAd;

  void loadAd({
    required BuildContext context,
    required Function() onLoaded,
    required Function() onComplete,
    required Function() onFailed,
  }) {
    MainJson mainJson = context.read<MainJson>();

    RewardedAd.load(
      adUnitId: !mainJson.isTestOn
          ? '${mainJson.data!['adIds']['google']['reward']}'
          : Platform.isIOS
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              onFailed();
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              if (mainJson.data![mainJson
                  .version]['globalConfig']['rewardOverRide']) {
                onComplete();
              }
              context.read<AdLoaderProvider>().isAdLoading = false;
              ad.dispose();
            },
            onAdClicked: (ad) {},
          );
          onLoaded();
          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              onComplete();
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          onFailed();
        },
      ),
    );
  }
}
