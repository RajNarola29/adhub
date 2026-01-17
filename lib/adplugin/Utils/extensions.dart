import 'package:flutter/material.dart';

import '../Ads/FullScreen/Ads.dart';

extension NavigationExtension on String {
  Future<void> performAction({
    required BuildContext context,
    required Function() onComplete,
  }) async {
    await AdsRN().showActionBasedAds(
      context: context,
      actionName: this,
      onComplete: () {
        onComplete();
      },
    );
  }

  Future<void> performScreenAction({
    required BuildContext context,
    required Function() onComplete,
  }) async {
    await AdsRN().showScreenActionBasedAds(
      context: context,
      actionName: this,
      onComplete: () {
        onComplete();
      },
    );
  }
}
