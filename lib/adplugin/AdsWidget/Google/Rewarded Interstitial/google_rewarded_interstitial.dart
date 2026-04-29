import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../AdLoader/ad_loader_provider.dart';
import '../../../MainJson/main_json.dart';
import '../../../Methods/google_init.dart';

class GoogleRewardedInterstitial {
  RewardedInterstitialAd? _rewardeInterstitialdAd;

  void loadAd({
    required BuildContext context,
    required Function() onLoaded,
    required Function() onComplete,
    required Function() onFailed,
  }) async {
    await GoogleInit.ready;
    MainJson mainJson = context.read<MainJson>();
    RewardedInterstitialAd.load(
      adUnitId: !mainJson.isTestOn
          ? '${mainJson.data!['ad_config']['admob_reward_inter']}'
          : Platform.isIOS
          ? 'ca-app-pub-3940256099942544/5354046379'
          : 'ca-app-pub-3940256099942544/6978759866',
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardeInterstitialdAd = ad;
          _rewardeInterstitialdAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {},
                onAdImpression: (ad) {},
                onAdFailedToShowFullScreenContent: (ad, err) {
                  onFailed();
                  ad.dispose();
                },
                onAdDismissedFullScreenContent: (ad) {
                  if (mainJson.data!['version_config'][mainJson.version]['globalConfig']['rewardOverRide']) {
                    onComplete();
                  }
                  context.read<AdLoaderProvider>().isAdLoading = false;
                  ad.dispose();
                },
                onAdClicked: (ad) {},
              );
          onLoaded();
          _rewardeInterstitialdAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
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
