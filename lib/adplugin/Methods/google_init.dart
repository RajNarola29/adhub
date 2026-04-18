import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

class GoogleInit {
  onInit() {
    // Run in background — do NOT await to avoid blocking startup by 2-3s.
    // AdMob (and all mediation adapters) initializes in the background;
    // ads will be ready by the time the user navigates to any screen.
    MobileAds.instance.initialize().then((_) {
      Logger().d("Google initialized");
    });
  }
}
