import 'dart:async';

import 'package:applovin_max/applovin_max.dart';

class AppLovinInit {
  /// Resolves when AppLovinMAX.initialize() completes.
  /// Ad loaders await this before loading, so ads work even on splash screens.
  static final Completer<void> _completer = Completer<void>();
  static Future<void> get ready => _completer.future;

  static void skip() {
    if (!_completer.isCompleted) _completer.complete();
  }

  static void init(String sdkKey) {
    AppLovinMAX.initialize(sdkKey).then((_) {
      if (!_completer.isCompleted) _completer.complete();
    });
  }
}
