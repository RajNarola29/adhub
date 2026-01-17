import 'dart:async';
import 'dart:convert';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'adplugin/MainJson/main_json.dart';
import 'adplugin/Methods/base_class.dart';
import 'adplugin/Utils/Alerts/alert_engine.dart';
import 'adplugin/Utils/Alerts/rate_us.dart';
import 'adplugin/Utils/navigation_service.dart';

class Adhub extends HookWidget {
  final Widget child;
  final String jsonUrl;
  final String apiKey;
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
    required this.apiKey,
    this.isAdsOn = true,
    this.isTestOn = false,
    this.nativeColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    MainJson mainJson = context.watch<MainJson>();

    showUpdateDialog(String url) {
      return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
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
    }

    rateUsDialog() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
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
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text("Rate"),
              onPressed: () {
                mainJson.isReviewDialogOpen = false;
                Navigator.pop(context);
                RateUs().showRateUsDialog();
              },
            ),
          ],
        ),
      );
    }

    mainFetchingLogic() {
      Future.microtask(() async {
        try {
          var headers = {'apikey': apiKey, 'Authorization': 'bearer $apiKey'};
          var dio = Dio();
          var response = await dio.request(
            jsonUrl,
            options: Options(method: 'GET', headers: headers),
          );

          if (response.statusCode == 200) {
            print(json.encode(response.data));

            if (response.data != null) {
              Future.microtask(() async {
                mainJson.data = response.data[0]['app_data'];
                mainJson.version = version;
                mainJson.isAdsOn = isAdsOn!;
                mainJson.isTestOn = isTestOn!;
                mainJson.nativeColor = nativeColor!;

                BaseClass().initAdNetworks(
                  context: context,
                  onInitComplete: () async {
                    if (mainJson.data?[version]['isUpdate'] ?? false) {
                      showUpdateDialog(mainJson.data?[version]['updateUrl']);
                      return;
                    }

                    Timer.periodic(
                      Duration(
                        seconds: mainJson
                            .data?[version]['globalConfig']['rateUsTimer'],
                      ),
                      (timer) async {
                        Logger().d("Rate Us Dialog");
                        final InAppReview inAppReview = InAppReview.instance;
                        bool isInAppReviewAvailable = await inAppReview
                            .isAvailable();
                        if (isInAppReviewAvailable &&
                            !mainJson.isReviewDialogOpen) {
                          mainJson.isReviewDialogOpen = true;
                          rateUsDialog();
                        }
                      },
                    );
                    print("oneSignalKey");
                    String oneSignalKey = mainJson.data?["one-signal"] ?? "";
                    if (oneSignalKey.isNotEmpty) {
                      OneSignal.initialize("${mainJson.data?["one-signal"]}");
                      OneSignal.Notifications.requestPermission(true);

                      OneSignal.Notifications.addPermissionObserver((state) {
                        print(state);
                      });
                    }

                    if (mainJson.data?[version]['isUserConsent']) {
                    } else {
                      await AppTrackingTransparency.requestTrackingAuthorization();
                    }
                    onComplete(context, mainJson.data!);
                  },
                );
              });
            }
          }
        } on DioException catch (e) {
          Future.microtask(() {
            AlertEngine.showCloseApp(context);
          });
        } catch (e) {
          print("Catche --------> ${e.toString()}");
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
