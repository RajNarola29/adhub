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

    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) async {
          bool isReady =
              (await AppLovinMAX.isInterstitialReady(
                mainJson.data!['adIds']['applovin']['fullScreen'],
              ))!;
          if (isReady) {
            onLoaded();
            AppLovinMAX.showInterstitial(
              mainJson.data!['adIds']['applovin']['fullScreen'],
            );
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

    AppLovinMAX.loadInterstitial(
      mainJson.data!['adIds']['applovin']['fullScreen'],
    );
  }
}
