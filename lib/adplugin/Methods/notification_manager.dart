import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'fcm_manager.dart';

class AdhubNotifications {
  /// Enables push notifications for the end user, across both OneSignal and
  /// FCM - both SDKs stay installed and active permanently (OneSignal is
  /// intentionally never removed, only unused for sending after the FCM
  /// cutover), so a toggle that only touched one would leave the user still
  /// (or no longer) subscribed on the other.
  ///
  /// Returns whether the user actually ended up opted in (mirrors
  /// `AdhubFcm.enableNotifications()`), so a caller like a Settings toggle
  /// can reflect the real OS permission result instead of assuming success.
  static Future<bool> enableNotifications() async {
    OneSignal.User.pushSubscription.optIn();
    if (AdhubFcm.isInitialized) {
      return AdhubFcm.enableNotifications();
    }
    return true;
  }

  /// Disables push notifications for the end user, across both OneSignal and
  /// FCM. See `enableNotifications()`.
  static Future<void> disableNotifications() async {
    OneSignal.User.pushSubscription.optOut();
    await AdhubFcm.disableNotifications();
  }

  /// Returns whether the user is currently opted-in to receive push
  /// notifications. FCM is the primary channel going forward, so this
  /// reflects FCM's state whenever it's configured for the app; falls back
  /// to OneSignal for apps that don't have `firebaseOptions` set yet.
  static Future<bool> get isOptedIn async {
    if (AdhubFcm.isInitialized) {
      return AdhubFcm.isOptedIn;
    }
    return OneSignal.User.pushSubscription.optedIn ?? false;
  }
}
