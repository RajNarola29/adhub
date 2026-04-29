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

    showUpdateDialog(String url) {
      if (Platform.isIOS) {
        return showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("New Update Available"),
            content: const Text(
              "New Update for your app is now available please update app to continue",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Update Now"),
                onPressed: () {
                  launchUrl(Uri.parse(url));
                },
              ),
            ],
          ),
        );
      } else {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "New Update Available",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              "New Update for your app is now available please update app to continue",
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("UPDATE NOW"),
                onPressed: () {
                  launchUrl(Uri.parse(url));
                },
              ),
            ],
          ),
        );
      }
    }

    showMigrationDialog(String url) {
      if (Platform.isIOS) {
        return showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("App Moved!"),
            content: const Text(
              "We have moved to a new and improved app! Please download it to continue.",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Download New App"),
                onPressed: () {
                  launchUrl(Uri.parse(url));
                },
              ),
            ],
          ),
        );
      } else {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "App Moved!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              "We have moved to a new and improved app! Please download it to continue.",
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("DOWNLOAD NEW APP"),
                onPressed: () {
                  launchUrl(Uri.parse(url));
                },
              ),
            ],
          ),
        );
      }
    }

    showSoftUpdateDialog(String url, String remoteVersion) {
      if (Platform.isIOS) {
        return showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("New Version Available"),
            content: const Text(
              "A newer version of the app is available. Would you like to update now?",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Update Later"),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                    'soft_update_last_shown_$remoteVersion',
                    DateTime.now().toIso8601String(),
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
              ),
              CupertinoDialogAction(
                child: const Text("Update Now"),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                    'soft_update_last_shown_$remoteVersion',
                    DateTime.now().toIso8601String(),
                  );
                  launchUrl(Uri.parse(url));
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      } else {
        return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "New Version Available",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              "A newer version of the app is available. Would you like to update now?",
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("UPDATE LATER"),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                    'soft_update_last_shown_$remoteVersion',
                    DateTime.now().toIso8601String(),
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("UPDATE NOW"),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                    'soft_update_last_shown_$remoteVersion',
                    DateTime.now().toIso8601String(),
                  );
                  launchUrl(Uri.parse(url));
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      }
    }

    rateUsDialog() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: NavigationService.navigatorKey.currentContext!,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Text(packageInfo.appName),
            content: const Text(
              "If you like our app. Would you mind to take moment to Rate Us.",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Not now"),
                onPressed: () {
                  mainJson.isReviewDialogOpen = false;
                  mainJson.hasInteractedWithRateUs = true;
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("Rate"),
                onPressed: () {
                  mainJson.isReviewDialogOpen = false;
                  mainJson.hasInteractedWithRateUs = true;
                  Navigator.pop(context);
                  RateUs().showRateUsDialog();
                },
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              packageInfo.appName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              "If you like our app. Would you mind to take moment to Rate Us.",
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("NOT NOW"),
                onPressed: () {
                  mainJson.isReviewDialogOpen = false;
                  mainJson.hasInteractedWithRateUs = true;
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("RATE"),
                onPressed: () {
                  mainJson.isReviewDialogOpen = false;
                  mainJson.hasInteractedWithRateUs = true;
                  Navigator.pop(context);
                  RateUs().showRateUsDialog();
                },
              ),
            ],
          ),
        );
      }
    }

    // Forward reference so showNetworkErrorDialog can call mainFetchingLogic
    // even though it is declared later in the build method.
    late final VoidCallback retryFetch;

    showNetworkErrorDialog() {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Network Issue"),
            content: const Text(
              "Slow internet or network error. Please check your connection and try again.",
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Retry"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  retryFetch();
                },
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Network Issue", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            content: const Text(
              "Slow internet or network error. Please check your connection and try again.",
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                child: const Text("RETRY"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  retryFetch();
                },
              ),
            ],
          ),
        );
      }
    }

    showMaintenanceDialog(String message) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Maintenance Break"),
            content: Text(message),
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Maintenance Break", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            content: Text(
              message,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        );
      }
    }

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
                  showMaintenanceDialog(appData?['maintenance_message'] ?? "Servers are currently under maintenance. Please try again later.");
                  return;
                }

                // 1. Migration Check
                if (appData?['is_migrated'] == true) {
                  showMigrationDialog(appData?['migration_url'] ?? "");
                  return;
                }

                // 2. Unknown Version
                if (currentVerData == null) {
                  showUpdateDialog(appData?['app_store_url'] ?? "");
                  return;
                }

                // 3. Explicit Force Update
                if (currentVerData['updateInfo']?['isUpdate'] == true) {
                  showUpdateDialog(
                    currentVerData['updateInfo']?['updateUrl'] ??
                        appData?['app_store_url'] ??
                        "",
                  );
                  return;
                }

                // 4. Soft Update
                final remoteCurrentVersion = appData?['current_version'];
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
                    showSoftUpdateDialog(
                      currentVerData['updateInfo']?['updateUrl'] ??
                          appData?['app_store_url'] ??
                          "",
                      remoteCurrentVersion,
                    );
                    // Do not return here, allow app to load in background
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
                        final InAppReview inAppReview = InAppReview.instance;
                        final bool isInAppReviewAvailable = await inAppReview
                            .isAvailable();
                        if (isInAppReviewAvailable &&
                            !mainJson.isReviewDialogOpen &&
                            !mainJson.hasInteractedWithRateUs) {
                          mainJson.isReviewDialogOpen = true;
                          rateUsDialog();
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
                    onComplete(context, mainJson.data!);
                  },
                );
              });
            }
          }
        } on DioException {
          Future.microtask(() {
            showNetworkErrorDialog();
          });
        } catch (e) {
          Future.microtask(() {
            showNetworkErrorDialog();
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
