import 'package:flutter/material.dart';

import '../Ads/FullScreen/Ads.dart';

extension NavigationExtension on String {
  void performAction({
    required BuildContext context,
    required VoidCallback onComplete,
  }) {
    Ads().showActionBasedAds(
      context: context,
      actionName: this,
      onComplete: onComplete,
    );
  }

  void performScreenAction({
    required BuildContext context,
    required VoidCallback onComplete,
  }) {
    Ads().showScreenActionBasedAds(
      context: context,
      actionName: this,
      onComplete: onComplete,
    );
  }
}
