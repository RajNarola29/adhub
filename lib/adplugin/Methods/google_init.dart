import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

class GoogleInit {
  /// Resolves when MobileAds.initialize() completes.
  /// Ad loaders await this before loading, so ads work even on splash screens.
  static final Completer<void> _completer = Completer<void>();
  static Future<void> get ready => _completer.future;

  onInit() {
    // Non-blocking — startup is not delayed.
    MobileAds.instance.initialize().then((_) {
      Logger().d("Google initialized");
      if (!_completer.isCompleted) _completer.complete();
    });
  }
}
