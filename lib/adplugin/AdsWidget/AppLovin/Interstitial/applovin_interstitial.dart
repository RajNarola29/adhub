import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';

class ApplovinInterstitial {
  void loadAd({
    required BuildContext context,
    required Function() onLoaded,
    required Function() onComplete,
    required Function() onFailed,
  }) {
    MainJson mainJson = context.read<MainJson>();

    final String? adUnitId = mainJson.data!['ad_config']['applovin_fullscreen'];
    if (adUnitId == null || adUnitId.isEmpty) {
      onFailed();
      return;
    }

    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) async {
          bool isReady = (await AppLovinMAX.isInterstitialReady(adUnitId))!;
          if (isReady) {
            onLoaded();
            AppLovinMAX.showInterstitial(adUnitId);
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
      ),
    );

    AppLovinMAX.loadInterstitial(adUnitId);
  }
}
