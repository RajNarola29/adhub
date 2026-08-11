import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/Alerts/adhub_dialogs.dart';

/// Every device subscribes to this topic so the panel can broadcast to
/// every app within a game's Firebase project without tracking individual
/// device tokens (mirrors OneSignal's "send to everyone subscribed" model).
const String adhubFcmBroadcastTopic = 'all_users';

/// SharedPreferences key gating the one-time OS notification permission
/// request - shared between `adhub.dart`'s OneSignal path and
/// [AdhubFcm.initialize] so only one of the two SDKs ever actually asks.
const String adhubNotificationPermissionAskedKey =
    'notification_permission_asked';

/// Per-app topic so the panel can target a single app (one platform build)
/// within a game's Firebase project, mirroring today's per-app
/// `onesignal_app_id` granularity - a Firebase project can hold several
/// app rows (e.g. Android + multiple iOS variants of the same game).
String _adhubFcmAppTopic(String appId) => 'app_$appId';

const AndroidNotificationChannel _adhubAndroidChannel =
    AndroidNotificationChannel(
      'adhub_default_channel',
      'Notifications',
      description: 'App notifications',
      importance: Importance.high,
    );

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// FCM is at-least-once delivery, not exactly-once - the same message can
/// legitimately arrive twice (well-documented, especially around app process
/// restarts). Persisted (not just in-memory) since redelivery can happen
/// across restarts, which is exactly when an in-memory set would be empty.
const String _seenMessageIdsPrefsKey = 'adhub_fcm_seen_message_ids';
const int _seenMessageIdsLimit = 20;

/// Timestamp of the last time `AdhubFcm.maybeReRequestPermission()` acted
/// (or, on its very first call, was seeded) - drives the 3-day recheck
/// cadence for users who denied (or never answered) the initial permission
/// prompt.
const String _reaskLastCheckPrefsKey = 'adhub_notification_reask_last_check';
const int _reaskIntervalDays = 3;

/// Registered as the top-level FCM background handler. Runs in its own
/// background isolate when a message arrives while the app is
/// backgrounded/killed - the `firebase_messaging` plugin requires this to be
/// registered (a class method or closure isn't accepted). Today's pushes are
/// always `notification`-payload (see `lib/fcm.ts` on the panel side), which
/// Android/iOS already auto-display via the OS without any app code running,
/// so there's nothing further to do here - this only becomes load-bearing if
/// a future data-only message is ever sent, and its absence is otherwise a
/// silent gap the plugin logs warnings about.
@pragma('vm:entry-point')
Future<void> _adhubFirebaseBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

Future<bool> _shouldShowMessage(RemoteMessage message) async {
  final String? messageId = message.messageId;
  if (messageId == null) return true;

  final prefs = await SharedPreferences.getInstance();
  final List<String> seen = prefs.getStringList(_seenMessageIdsPrefsKey) ?? [];
  if (seen.contains(messageId)) return false;

  seen.add(messageId);
  final List<String> trimmed = seen.length > _seenMessageIdsLimit
      ? seen.sublist(seen.length - _seenMessageIdsLimit)
      : seen;
  await prefs.setStringList(_seenMessageIdsPrefsKey, trimmed);
  return true;
}

/// Firebase Cloud Messaging setup for adhub apps.
///
/// [options] must come from the consuming app's own generated
/// `firebase_options.dart` (via `flutterfire configure`) - unlike OneSignal's
/// app ID, this can't be fetched from the remote config JSON at runtime,
/// it has to be baked into the app at build time.
class AdhubFcm {
  static bool _initialized = false;
  static String? _appId;

  /// Whether `initialize()` has actually run for this app (i.e. it has
  /// `firebaseOptions` configured) - lets callers know whether FCM's own
  /// state is meaningful yet, or whether they should fall back to another
  /// channel.
  static bool get isInitialized => _appId != null;

  static Future<void> initialize(FirebaseOptions options, String appId) async {
    _appId = appId;
    if (_initialized) return;
    _initialized = true;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }

    FirebaseMessaging.onBackgroundMessage(_adhubFirebaseBackgroundHandler);

    await _initLocalNotifications();

    // Let iOS present the native foreground banner directly - the
    // Notification Service Extension already attaches the image to it, so
    // there's no need for a separate local notification like on Android
    // (and suppressing this while also creating our own local notification
    // is what caused foreground pushes to double-display on iOS).
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // The single explicit requester for the OS notification permission
    // whenever FCM is configured for this app - see the matching skip in
    // adhub.dart's OneSignal block. It's one shared OS-level permission, so
    // only one SDK should ever actually request it; OneSignal only requests
    // it itself as a fallback when Firebase isn't configured at all.
    final prefs = await SharedPreferences.getInstance();
    final bool alreadyAsked =
        prefs.getBool(adhubNotificationPermissionAskedKey) ?? false;
    if (!alreadyAsked) {
      await prefs.setBool(adhubNotificationPermissionAskedKey, true);
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // On iOS, subscribeToTopic throws apns-token-not-set if called before
    // the OS has handed the app its APNs token, which can take a moment
    // right after a fresh install/permission grant.
    await _ensureApnsTokenReady();

    await FirebaseMessaging.instance.subscribeToTopic(adhubFcmBroadcastTopic);
    await FirebaseMessaging.instance.subscribeToTopic(_adhubFcmAppTopic(appId));

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpen(initialMessage);
    }
  }

  static Future<void> _ensureApnsTokenReady() async {
    if (!Platform.isIOS) return;
    for (int attempt = 0; attempt < 10; attempt++) {
      final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final String? launchUrlPayload = response.payload;
        if (launchUrlPayload != null && launchUrlPayload.isNotEmpty) {
          _openUrl(launchUrlPayload);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_adhubAndroidChannel);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    // iOS shows the native banner directly (image already attached by the
    // Notification Service Extension) - only Android needs a manually
    // created local notification while the app is foregrounded.
    if (Platform.isIOS) return;

    final notification = message.notification;
    if (notification == null) return;
    if (!await _shouldShowMessage(message)) return;

    final String? imageUrl = notification.android?.imageUrl;
    final Uint8List? imageBytes = imageUrl == null
        ? null
        : await _downloadImageBytes(imageUrl);

    BigPictureStyleInformation? androidStyle;
    if (imageBytes != null) {
      androidStyle = BigPictureStyleInformation(
        ByteArrayAndroidBitmap(imageBytes),
      );
    }

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _adhubAndroidChannel.id,
          _adhubAndroidChannel.name,
          channelDescription: _adhubAndroidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: androidStyle,
        ),
      ),
      payload: message.data['launchUrl'] as String?,
    );
  }

  static Future<Uint8List?> _downloadImageBytes(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      return data == null ? null : Uint8List.fromList(data);
    } catch (_) {
      // Image failed to download - fall back to a text-only notification
      // rather than dropping the notification entirely.
      return null;
    }
  }

  static void _handleMessageOpen(RemoteMessage message) {
    final String? launchUrlStr = message.data['launchUrl'] as String?;
    if (launchUrlStr != null && launchUrlStr.isNotEmpty) {
      _openUrl(launchUrlStr);
    }
  }

  static Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Malformed/unlaunchable URL from a notification payload - ignore.
    }
  }

  /// Enables push notifications for the end user. No-op if `initialize()`
  /// hasn't run yet (e.g. this app has no `firebaseOptions` configured) -
  /// there's no topic to (re)subscribe to in that case.
  ///
  /// Unlike `initialize()`, this is triggered by an explicit user action
  /// (e.g. a Settings toggle), so it always requests the OS permission if
  /// it isn't already granted, rather than relying on the one-time
  /// first-launch ask. Returns whether the user actually ended up opted
  /// in, so callers can reflect the real result instead of assuming the
  /// toggle succeeded.
  static Future<bool> enableNotifications() async {
    final String? appId = _appId;
    if (appId == null) return false;

    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    bool granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!granted) {
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (!granted) {
      // The OS already refused once, so requestPermission() above won't
      // have shown any UI (mainly Android) - fall back to adhub's own
      // dialog, which deep-links to the device's app-settings screen.
      final PermissionStatus status = await Permission.notification.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        await AdhubDialogs.showNotificationPermissionDialog();
      }
      return false;
    }

    await _ensureApnsTokenReady();
    await FirebaseMessaging.instance.subscribeToTopic(adhubFcmBroadcastTopic);
    await FirebaseMessaging.instance.subscribeToTopic(_adhubFcmAppTopic(appId));
    return true;
  }

  /// Disables push notifications for the end user. No-op if `initialize()`
  /// hasn't run yet, mirroring `enableNotifications()`.
  static Future<void> disableNotifications() async {
    final String? appId = _appId;
    if (appId == null) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic(
      adhubFcmBroadcastTopic,
    );
    await FirebaseMessaging.instance.unsubscribeFromTopic(
      _adhubFcmAppTopic(appId),
    );
  }

  /// Whether the user has granted notification permission.
  static Future<bool> get isOptedIn async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Call on every app open. If the user is already opted in, does nothing.
  /// Otherwise, checks in at most once every [_reaskIntervalDays] days: if
  /// the OS will still show its native permission popup (mainly an Android
  /// possibility - iOS essentially never re-shows it after an explicit
  /// answer), triggers that; otherwise shows adhub's own custom dialog,
  /// which deep-links to the device's app-settings screen since that's the
  /// only way back in once permanently denied.
  static Future<void> maybeReRequestPermission() async {
    final PermissionStatus status = await Permission.notification.status;
    if (status.isGranted || status.isLimited || status.isProvisional) return;

    final prefs = await SharedPreferences.getInstance();
    final String? lastCheckStr = prefs.getString(_reaskLastCheckPrefsKey);

    if (lastCheckStr == null) {
      // First time this check has ever run - just start the clock, don't
      // immediately re-prompt right after the still-fresh initial ask.
      await prefs.setString(_reaskLastCheckPrefsKey, DateTime.now().toIso8601String());
      return;
    }

    final DateTime lastCheck = DateTime.parse(lastCheckStr);
    if (DateTime.now().difference(lastCheck).inDays < _reaskIntervalDays) return;

    await prefs.setString(_reaskLastCheckPrefsKey, DateTime.now().toIso8601String());

    if (status.isPermanentlyDenied || status.isRestricted) {
      await AdhubDialogs.showNotificationPermissionDialog();
    } else {
      // Still possibly re-askable (mainly Android's first-denial window) -
      // harmless no-op if the OS won't actually show anything.
      await Permission.notification.request();
    }
  }
}
