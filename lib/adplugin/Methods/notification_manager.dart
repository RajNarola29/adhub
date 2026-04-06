import 'package:onesignal_flutter/onesignal_flutter.dart';

class AdhubNotifications {
  /// Enables push notifications for the end user.
  static void enableNotifications() {
    OneSignal.User.pushSubscription.optIn();
  }

  /// Disables push notifications for the end user.
  static void disableNotifications() {
    OneSignal.User.pushSubscription.optOut();
  }

  /// Returns whether the user is currently opted-in to receive push notifications.
  static bool get isOptedIn {
    return OneSignal.User.pushSubscription.optedIn ?? false;
  }
}
