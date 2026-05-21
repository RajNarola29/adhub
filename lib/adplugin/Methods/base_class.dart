import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../MainJson/main_json.dart';
import 'google_init.dart';

class BaseClass {
  Future<void> initAdNetworks({
    required BuildContext context,
    required Function() onInitComplete,
  }) async {
    MainJson mainJson = context.read<MainJson>();

    // ATT must run before UMP consent and MobileAds init on iOS.
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    final bool googleEnabled =
        mainJson.data!['version_config'][mainJson.version]['adNetwork']['google'] ?? false;
    final bool appLovinEnabled =
        mainJson.data!['version_config'][mainJson.version]['adNetwork']['appLovin'] ?? false;

    if (!googleEnabled && !appLovinEnabled) {
      mainJson.isAdsOn = false;
    }

    if (googleEnabled) {
      // Non-blocking — UMP consent + MobileAds.initialize run in background.
      GoogleInit().onInit();
    } else {
      // Google not enabled — resolve the completer so any await GoogleInit.ready
      // calls in GoogleBanner/GoogleNative don't hang forever.
      GoogleInit.skip();
    }
    if (appLovinEnabled) {
      // Run AppLovin init in background — do NOT await to avoid blocking startup
      AppLovinMAX.initialize(
        (mainJson.data!['ad_config']['applovin_sdk_key'] != null &&
                mainJson.data!['ad_config']['applovin_sdk_key'] != "")
            ? mainJson.data!['ad_config']['applovin_sdk_key']
            : "xiAs_Fs3BiExPelVuawzyDTU2Sy4GL2d6KB1c7C1loiv64T5oquTwRRIJbHC3qO0qRI_65NChIkGy3U2i6rWXn",
      );
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      onInitComplete();
    });
  }
}
