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
                try { launchUrl(Uri.parse(url)); } catch (_) {}
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.system_update_rounded, size: 60, color: Colors.blueAccent),
            title: Text(
              "New Update Available",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              "New update for your app is now available. Please update the app to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("UPDATE NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  try { launchUrl(Uri.parse(url)); } catch (_) {}
                },
              ),
            ],
          );
        },
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
                try { launchUrl(Uri.parse(url)); } catch (_) {}
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.deepPurpleAccent),
            title: Text(
              "App Moved!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              "We have moved to a new and improved app! Please download it to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("DOWNLOAD NEW APP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  try { launchUrl(Uri.parse(url)); } catch (_) {}
                },
              ),
            ],
          );
        },
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
                prefs.setString('soft_update_last_shown_$remoteVersion', DateTime.now().toIso8601String());
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                onProceed();
              },
            ),
            CupertinoDialogAction(
              child: const Text("Update Now"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('soft_update_last_shown_$remoteVersion', DateTime.now().toIso8601String());
                try { launchUrl(Uri.parse(url)); } catch (_) {}
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
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          final secondaryColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.system_update, size: 60, color: Colors.blueAccent),
            title: Text(
              "New Version Available",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              "A newer version of the app is available. Would you like to update now?",
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("LATER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('soft_update_last_shown_$remoteVersion', DateTime.now().toIso8601String());
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("UPDATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('soft_update_last_shown_$remoteVersion', DateTime.now().toIso8601String());
                        try { launchUrl(Uri.parse(url)); } catch (_) {}
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        onProceed();
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> showRateUsDialog(MainJson mainJson) async {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => CupertinoAlertDialog(
          title: Text(packageInfo.appName),
          content: const Text(
            "If you like our app, would you mind taking a moment to rate us?",
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Not Now"),
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
                RateUs().showRateUsDialog(fallbackUrl: mainJson.data?['app']?['app_store_url'] ?? '');
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          final secondaryColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.star_rounded, size: 60, color: Colors.amber),
            title: Text(
              "Enjoying ${packageInfo.appName}?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              "If you like our app, would you mind taking a moment to rate us?",
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("RATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('rate_us_completed', true);
                        mainJson.isReviewDialogOpen = false;
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        RateUs().showRateUsDialog(fallbackUrl: mainJson.data?['app']?['app_store_url'] ?? '');
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
            title: Text(
              "Network Issue",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              "Slow internet or network error. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("RETRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  retryFetch();
                },
              ),
            ],
          );
        },
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
        builder: (dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final titleColor = isDark ? Colors.white : Colors.black87;
          final contentColor = isDark ? Colors.white70 : Colors.black54;
          return AlertDialog(
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.build_circle_rounded, size: 60, color: Colors.orangeAccent),
            title: Text(
              "Maintenance Break",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: contentColor, fontSize: 16),
            ),
            contentPadding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 10),
          );
        },
      );
    }
  }
}
