import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';

class ApplovinRewarded {
  void loadAd({
    required BuildContext context,
    required Function() onLoaded,
    required Function() onComplete,
    required Function() onFailed,
  }) {
    MainJson mainJson = context.read<MainJson>();

    final String? adUnitId = mainJson.data!['ad_config']['applovin_reward'];
    if (adUnitId == null || adUnitId.isEmpty) {
      onFailed();
      return;
    }

    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (ad) async {
          bool isReady = (await AppLovinMAX.isRewardedAdReady(adUnitId))!;
          if (isReady) {
            onLoaded();
            AppLovinMAX.showRewardedAd(adUnitId);
          }
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          onFailed();
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          onComplete();
        },
        onAdReceivedRewardCallback: (ad, reward) {},
      ),
    );

    AppLovinMAX.loadRewardedAd(adUnitId);
  }
}
