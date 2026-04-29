import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../MainJson/main_json.dart';
import '../navigation_service.dart';
import 'rate_us.dart';

class AdhubDialogs {
  static void showUpdateDialog(BuildContext context, String url) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text("New Update Available"),
          content: const Text(
            "New update for your app is now available. Please update the app to continue.",
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(Icons.system_update_rounded, size: 60, color: Colors.blueAccent),
          title: const Text(
            "New Update Available",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "New update for your app is now available. Please update the app to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("UPDATE NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                launchUrl(Uri.parse(url));
              },
            ),
          ],
        ),
      );
    }
  }

  static void showMigrationDialog(BuildContext context, String url) {
    if (Platform.isIOS) {
      showCupertinoDialog(
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.deepPurpleAccent),
          title: const Text(
            "App Moved!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "We have moved to a new and improved app! Please download it to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("DOWNLOAD NEW APP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                launchUrl(Uri.parse(url));
              },
            ),
          ],
        ),
      );
    }
  }

  static void showSoftUpdateDialog(BuildContext context, String url, String remoteVersion, VoidCallback onProceed) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
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
                onProceed();
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
                onProceed();
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(Icons.system_update, size: 60, color: Colors.blueAccent),
          title: const Text(
            "New Version Available",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "A newer version of the app is available. Would you like to update now?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("LATER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString(
                        'soft_update_last_shown_$remoteVersion',
                        DateTime.now().toIso8601String(),
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      onProceed();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("UPDATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString(
                        'soft_update_last_shown_$remoteVersion',
                        DateTime.now().toIso8601String(),
                      );
                      launchUrl(Uri.parse(url));
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      onProceed();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  static Future<void> showRateUsDialog(MainJson mainJson) async {
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('rate_us_not_now_timestamp', DateTime.now().toIso8601String());
                mainJson.isReviewDialogOpen = false;
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text("Rate"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('rate_us_completed', true);
                mainJson.isReviewDialogOpen = false;
                if (!context.mounted) return;
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(Icons.star_rounded, size: 60, color: Colors.amber),
          title: Text(
            "Enjoying ${packageInfo.appName}?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "If you like our app, would you mind taking a moment to rate us?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("NOT NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('rate_us_not_now_timestamp', DateTime.now().toIso8601String());
                      mainJson.isReviewDialogOpen = false;
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("RATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('rate_us_completed', true);
                      mainJson.isReviewDialogOpen = false;
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      RateUs().showRateUsDialog();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  static void showNetworkErrorDialog(BuildContext context, VoidCallback retryFetch) {
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
          title: const Text("Network Issue", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
          content: const Text(
            "Slow internet or network error. Please check your connection and try again.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("RETRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  static void showMaintenanceDialog(BuildContext context, String message) {
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.build_circle_rounded, size: 60, color: Colors.orangeAccent),
          title: const Text("Maintenance Break", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
          contentPadding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 10),
        ),
      );
    }
  }
}
