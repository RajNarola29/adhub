import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adplugin/MainJson/main_json.dart';
import 'adplugin/Methods/base_class.dart';
import 'adplugin/Methods/fcm_manager.dart';
import 'adplugin/Utils/Alerts/adhub_dialogs.dart';

export 'adplugin/Methods/notification_manager.dart';
export 'adplugin/Methods/fcm_manager.dart';

/// `jsonUrl` always points at `.../apps/{id}.json` (see r2-generator.ts in
/// the panel) - reused here as the FCM per-app topic id instead of adding a
/// separate config value every consuming app would have to pass in.
String? _extractAppIdFromJsonUrl(String jsonUrl) {
  return RegExp(r'/(\d+)\.json$').firstMatch(jsonUrl)?.group(1);
}

bool _isVersionOlder(String current, String remote) {
  try {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> remoteParts = remote.split('.').map(int.parse).toList();
    for (int i = 0; i < currentParts.length && i < remoteParts.length; i++) {
      if (currentParts[i] < remoteParts[i]) return true;
      if (currentParts[i] > remoteParts[i]) return false;
    }
    return currentParts.length < remoteParts.length;
  } catch (e) {
    return false;
  }
}

class Adhub extends HookWidget {
  static String appStoreUrl = "";
  static String contactUs = "";
  static String privacyPolicy = "";
  static Map content = {};
  static Map extra = {};

  final Widget child;
  final String jsonUrl;
  final String version;
  final Function(BuildContext context, Map mainJson) onComplete;
  final bool? isAdsOn;
  final bool? isTestOn;
  final Color? nativeColor;
  final Color? nativeBorderColor;
  final EdgeInsets? nativeMargin;
  final FirebaseOptions? firebaseOptions;

  const Adhub({
    required this.child,
    required this.onComplete,
    required this.version,
    required this.jsonUrl,
    this.isAdsOn = true,
    this.isTestOn = false,
    this.nativeColor = Colors.white,
    this.nativeBorderColor = Colors.white,
    this.nativeMargin = EdgeInsets.zero,
    this.firebaseOptions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.watch<MainJson>();
    final rateUsTimerRef = useRef<Timer?>(null);

    late VoidCallback retryFetch;

    mainFetchingLogic() {
      retryFetch = mainFetchingLogic;
      Future.microtask(() async {
        try {
          var dio = Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          var response = await dio.request(
            jsonUrl,
            options: Options(method: 'GET'),
          );

          if (response.statusCode == 200) {
            if (response.data != null) {
              Future.microtask(() async {
                mainJson.init(
                  data: response.data,
                  version: version,
                  isAdsOn: isAdsOn!,
                  isTestOn: isTestOn!,
                  nativeColor: nativeColor!,
                  nativeBorderColor: nativeBorderColor!,
                  nativeMargin: nativeMargin!,
                );

                final appData = mainJson.data?['app'];

                Adhub.appStoreUrl = appData?['app_store_url'] ?? "";
                Adhub.contactUs = appData?['contact_us'] ?? "";
                Adhub.privacyPolicy = appData?['privacy_policy'] ?? "";
                Adhub.content = mainJson.data?['content'] ?? {};
                Adhub.extra = mainJson.data?['extra'] ?? {};

                final versionConfig = mainJson.data?['version_config'];
                final currentVerData = versionConfig?[version];

                // 0. Maintenance Check
                if (appData?['is_maintenance'] == true) {
                  AdhubDialogs.showMaintenanceDialog(
                    context,
                    appData?['maintenance_message'] ??
                        "Servers are currently under maintenance. Please try again later.",
                  );
                  return;
                }

                // 1. Migration Check
                if (appData?['is_migrated'] == true) {
                  AdhubDialogs.showMigrationDialog(
                    context,
                    appData?['migration_url']?.toString().isNotEmpty == true
                        ? appData!['migration_url']
                        : appData?['app_store_url'] ?? "",
                  );
                  return;
                }

                // 2. Unknown Version
                if (currentVerData == null) {
                  AdhubDialogs.showUpdateDialog(
                    context,
                    appData?['app_store_url'] ?? "",
                  );
                  return;
                }

                // 3. Explicit Force Update
                if (currentVerData['updateInfo']?['isUpdate'] == true) {
                  AdhubDialogs.showUpdateDialog(
                    context,
                    currentVerData['updateInfo']?['updateUrl'] ??
                        appData?['app_store_url'] ??
                        "",
                  );
                  return;
                }

                // 4. Soft Update
                final remoteCurrentVersion = appData?['current_version'];
                bool isSoftUpdatePending = false;
                if (remoteCurrentVersion != null &&
                    _isVersionOlder(version, remoteCurrentVersion)) {
                  final prefs = await SharedPreferences.getInstance();
                  final lastShownStr = prefs.getString(
                    'soft_update_last_shown_$remoteCurrentVersion',
                  );
                  bool shouldShow = true;
                  if (lastShownStr != null) {
                    final lastShown = DateTime.parse(lastShownStr);
                    if (DateTime.now().difference(lastShown).inHours < 48) {
                      shouldShow = false;
                    }
                  }

                  if (shouldShow) {
                    isSoftUpdatePending = true;
                  }
                }

                BaseClass().initAdNetworks(
                  context: context,
                  onInitComplete: () async {
                    final prefs = await SharedPreferences.getInstance();
                    rateUsTimerRef.value = Timer.periodic(
                      Duration(
                        seconds: mainJson
                                .data?['version_config']?[version]?['globalConfig']?['rateUsTimer'] ??
                            30,
                      ),
                      (timer) async {
                        final bool rateUsCompleted =
                            prefs.getBool('rate_us_completed') ?? false;

                        if (rateUsCompleted) {
                          timer.cancel();
                          return;
                        }

                        final String? notNowStr = prefs.getString(
                          'rate_us_not_now_timestamp',
                        );
                        if (notNowStr != null) {
                          final notNowTime = DateTime.parse(notNowStr);
                          if (DateTime.now().difference(notNowTime).inDays <
                              3) {
                            timer.cancel();
                            return;
                          }
                        }

                        final InAppReview inAppReview = InAppReview.instance;
                        final bool isInAppReviewAvailable = await inAppReview
                            .isAvailable();

                        if (isInAppReviewAvailable &&
                            !mainJson.isReviewDialogOpen) {
                          mainJson.isReviewDialogOpen = true;
                          AdhubDialogs.showRateUsDialog(mainJson);
                        }
                      },
                    );
                    final String oneSignalKey =
                        mainJson.data?['app']?['onesignal_app_id'] ?? "";

                    if (oneSignalKey.isNotEmpty) {
                      OneSignal.initialize(oneSignalKey);

                      // The OS notification permission is a single shared
                      // permission - only one SDK should ever actually
                      // request it. FCM's requestPermission() is the richer,
                      // primary path (see the matching request in
                      // AdhubFcm.initialize()), so OneSignal only requests it
                      // itself as a fallback for apps that don't have
                      // Firebase configured yet.
                      if (firebaseOptions == null &&
                          !OneSignal.Notifications.permission) {
                        final bool alreadyAsked =
                            prefs.getBool(adhubNotificationPermissionAskedKey) ??
                                false;
                        if (!alreadyAsked) {
                          await prefs.setBool(
                            adhubNotificationPermissionAskedKey,
                            true,
                          );
                          await OneSignal.Notifications.requestPermission(false);
                        }
                      }
                    }

                    if (firebaseOptions != null) {
                      final appId = _extractAppIdFromJsonUrl(jsonUrl);
                      if (appId != null) {
                        // Non-blocking - mirrors GoogleInit/AppLovin above so
                        // Firebase init, the permission prompt, and topic
                        // subscribes don't delay showing the app.
                        unawaited(
                          AdhubFcm.initialize(firebaseOptions!, appId).catchError((
                            Object e,
                          ) {
                            debugPrint('Adhub: AdhubFcm.initialize failed: $e');
                          }),
                        );
                      } else {
                        debugPrint(
                          'Adhub: firebaseOptions was provided but no app id '
                          'could be extracted from jsonUrl ("$jsonUrl") - '
                          'expected it to end in "/<digits>.json". FCM will '
                          'not be initialized.',
                        );
                      }
                    }

                    // Runs regardless of which SDK is configured - checks
                    // the shared OS notification permission and, if still
                    // denied, re-prompts (or falls back to a settings
                    // deep-link) at most once every 3 days. Non-blocking for
                    // the same reason as AdhubFcm.initialize() above.
                    unawaited(
                      AdhubFcm.maybeReRequestPermission().catchError((Object e) {
                        debugPrint('Adhub: maybeReRequestPermission failed: $e');
                      }),
                    );
                    if (!context.mounted) return;

                    if (isSoftUpdatePending) {
                      AdhubDialogs.showSoftUpdateDialog(
                        context,
                        currentVerData?['updateInfo']?['updateUrl'] ??
                            appData?['app_store_url'] ??
                            "",
                        remoteCurrentVersion!,
                        () {
                          onComplete(context, mainJson.data!);
                        },
                      );
                    } else {
                      onComplete(context, mainJson.data!);
                    }
                  },
                );
              });
            }
          }
        } on DioException {
          Future.microtask(() {
            AdhubDialogs.showNetworkErrorDialog(context, retryFetch);
          });
        } catch (e) {
          Future.microtask(() {
            AdhubDialogs.showNetworkErrorDialog(context, retryFetch);
          });
        }
      });
    }

    useEffect(() {
      mainFetchingLogic();
      return () {
        rateUsTimerRef.value?.cancel();
      };
    }, []);
    return child;
  }
}
