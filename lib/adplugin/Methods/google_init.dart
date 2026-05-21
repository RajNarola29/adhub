import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleInit {
  /// Resolves when MobileAds.initialize() completes.
  /// Ad loaders await this before loading, so ads work even on splash screens.
  static final Completer<void> _completer = Completer<void>();
  static Future<void> get ready => _completer.future;

  void onInit() {
    _gatherConsentThenInit();
  }

  static void skip() {
    if (!_completer.isCompleted) _completer.complete();
  }

  /// Requests UMP consent info, shows form if required, then initializes ads.
  void _gatherConsentThenInit() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        // loadAndShowConsentFormIfRequired handles all cases:
        // shows form when required, skips silently when not needed.
        ConsentForm.loadAndShowConsentFormIfRequired(
          (FormError? formError) => _initMobileAds(),
        );
      },
      (FormError error) => _initMobileAds(),
    );
  }

  void _initMobileAds() {
    MobileAds.instance.initialize().then((_) {
      if (!_completer.isCompleted) _completer.complete();
    });
  }
}
