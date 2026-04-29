import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'adplugin/MainJson/main_json.dart';
import 'adplugin/Methods/base_class.dart';
import 'adplugin/Utils/Alerts/rate_us.dart';
import 'adplugin/Utils/navigation_service.dart';
import 'adplugin/Utils/Alerts/adhub_dialogs.dart';

export 'adplugin/Methods/notification_manager.dart';

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

  const Adhub({
    required this.child,
    required this.onComplete,
    required this.version,
    required this.jsonUrl,
    this.isAdsOn = true,
    this.isTestOn = false,
    this.nativeColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.watch<MainJson>();


    late final VoidCallback retryFetch;

    mainFetchingLogic() {
      retryFetch = mainFetchingLogic;
      Future.microtask(() async {
        try {
          var dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));
          var response = await dio.request(
            jsonUrl,
            options: Options(method: 'GET'),
          );

          if (response.statusCode == 200) {
            if (response.data != null) {
              Future.microtask(() async {
                mainJson.data = response.data;
                mainJson.version = version;
                mainJson.isAdsOn = isAdsOn!;
                mainJson.isTestOn = isTestOn!;
                mainJson.nativeColor = nativeColor!;

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
                  AdhubDialogs.showMaintenanceDialog(context, appData?['maintenance_message'] ?? "Servers are currently under maintenance. Please try again later.");
                  return;
                }

                // 1. Migration Check
                if (appData?['is_migrated'] == true) {
                  AdhubDialogs.showMigrationDialog(context, appData?['migration_url'] ?? "");
                  return;
                }

                // 2. Unknown Version
                if (currentVerData == null) {
                  AdhubDialogs.showUpdateDialog(context, appData?['app_store_url'] ?? "");
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
                    Timer.periodic(
                      Duration(
                        seconds: mainJson
                            .data?['version_config']?[version]['globalConfig']['rateUsTimer'],
                      ),
                      (timer) async {
                        final prefs = await SharedPreferences.getInstance();
                        final bool rateUsCompleted = prefs.getBool('rate_us_completed') ?? false;

                        if (rateUsCompleted) {
                          timer.cancel();
                          return;
                        }

                        final String? notNowStr = prefs.getString('rate_us_not_now_timestamp');
                        if (notNowStr != null) {
                          final notNowTime = DateTime.parse(notNowStr);
                          if (DateTime.now().difference(notNowTime).inDays < 7) {
                            timer.cancel();
                            return;
                          }
                        }

                        final InAppReview inAppReview = InAppReview.instance;
                        final bool isInAppReviewAvailable = await inAppReview.isAvailable();

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

                      if (!OneSignal.Notifications.permission) {
                        await OneSignal.Notifications.requestPermission(true);
                      }
                    }

                    if (Platform.isIOS) {
                      await AppTrackingTransparency.requestTrackingAuthorization();
                    }
                    if (!context.mounted) return;
                    
                    if (isSoftUpdatePending) {
                      AdhubDialogs.showSoftUpdateDialog(
                        context,
                        currentVerData?['updateInfo']?['updateUrl'] ?? appData?['app_store_url'] ?? "",
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
      Future.microtask(() {
        mainFetchingLogic();
      });
      return () {};
    }, []);
    return Scaffold(body: child);
  }
}
