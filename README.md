# AdHub

`adhub` is a Flutter package that simplifies multi-network ad integration through a **remote JSON configuration**. One unified API handles **Google AdMob** and **AppLovin MAX** — with built-in app versioning, maintenance mode, network resilience, and lifecycle utilities.

[![pub.dev version](https://img.shields.io/pub/v/adhub.svg)](https://pub.dev/packages/adhub)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/RajNarola29/adhub/blob/main/LICENSE)

---

## What does this package do?

| Feature | Description |
|---|---|
| 📡 **Remote JSON Config** | All ad IDs, flags, and version rules fetched from your own URL |
| 📱 **Banner Ads** | Google AdMob + AppLovin MAX |
| 🎬 **Interstitial Ads** | Google AdMob + AppLovin MAX |
| 💰 **Rewarded Ads** | Google AdMob + AppLovin MAX |
| 🎁 **Rewarded Interstitial** | Google AdMob |
| 🖼️ **Native Ads** | Google AdMob |
| 🔄 **AdLoader Overlay** | Full-screen loading spinner while ads load |
| 🔔 **Push Notifications** | FCM (primary) + OneSignal (fallback) - see [Push Notifications](#push-notifications-fcm) below |
| ⭐ **In-App Review** | Timer-based rate-us prompt |
| 🛡️ **Maintenance Mode** | Server-side kill-switch — blocks app with a custom message |
| 🌐 **Network Resilience** | 10-second timeout + retry dialog |
| 🔼 **Force/Soft Update** | Version-gate users to the latest release |

---

## Installation

To add this package to your Flutter project, run:

```bash
flutter pub add adhub
```

---

## Push Notifications (FCM)

FCM is the primary push channel; OneSignal stays installed and is only used as a fallback for apps that don't pass `firebaseOptions` yet. To wire up FCM for a consuming app:

1. Run `flutterfire configure` in the app to generate `lib/firebase_options.dart`.
2. Pass the generated options into `Adhub`:
   ```dart
   Adhub(
     firebaseOptions: DefaultFirebaseOptions.currentPlatform,
     jsonUrl: jsonUrl,
     // ...
   )
   ```
3. **Android** - target SDK 33+ requires the `POST_NOTIFICATIONS` runtime permission; `permission_handler` (a transitive dependency of this package) handles the request, but the permission must still be declared in the app's `AndroidManifest.xml`.
4. **Android notification icon (required)** - Android strips all color from the notification tray icon and only reads the alpha channel. A full-color icon (e.g. reusing the launcher icon) renders as a solid white blob on stock/near-stock Android (confirmed on Motorola), or on some OEM skins like Samsung One UI silently falls back to showing the full-color app icon instead - neither is correct, and which one you get is device-dependent, not a coincidence. adhub references a **fixed resource name**, not a configurable parameter (mirrors the convention OneSignal itself uses for `ic_stat_onesignal_default`) - every consuming app must provide:
   - A white silhouette on a **transparent** background (not white-on-white - it needs a real alpha channel or there's no shape to extract) named `ic_stat_notify_default`, placed at:
     ```
     android/app/src/main/res/drawable-mdpi/ic_stat_notify_default.png      (24x24)
     android/app/src/main/res/drawable-hdpi/ic_stat_notify_default.png      (36x36)
     android/app/src/main/res/drawable-xhdpi/ic_stat_notify_default.png     (48x48)
     android/app/src/main/res/drawable-xxhdpi/ic_stat_notify_default.png    (72x72)
     android/app/src/main/res/drawable-xxxhdpi/ic_stat_notify_default.png   (96x96)
     ```
     Generate via Android Studio's **File > New > Image Asset > Notification Icons** (auto-strips color and outputs all 5 sizes from any source image), or the free [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html) web tool. Keep the source shape simple and bold - fine detail or text won't survive at 24px.
   - The following meta-data in the app's own `AndroidManifest.xml` (inside `<application>`), so FCM can also show the icon correctly when the app is backgrounded/killed and no app code runs:
     ```xml
     <meta-data
         android:name="com.google.firebase.messaging.default_notification_icon"
         android:resource="@drawable/ic_stat_notify_default" />
     ```
   If either piece is missing, the notification icon will be broken or fail to resolve entirely - this isn't optional for apps using FCM through adhub.
5. **iOS** - enable the "Push Notifications" capability and the "Background Modes > Remote notifications" background mode in Xcode, and upload an APNs auth key (or certificate) to the Firebase console for the app.
6. **iOS image-rich pushes (optional)** - to have notification images render, add a Notification Service Extension target to the app that downloads and attaches the image; FCM alone won't do this on iOS.

Use `AdhubNotifications.enableNotifications()` / `.disableNotifications()` / `.isOptedIn` (all `Future`-based) to build a notification toggle in your app's settings screen - they transparently keep both FCM topic subscriptions and OneSignal opt-in state in sync.

---

## Google AdMob Test IDs

Use these when setting `isTestOn: true` during development.

### Android

| Format | Test ID |
|---|---|
| **App ID** | `ca-app-pub-3940256099942544~3347511713` |
| **Banner** | `ca-app-pub-3940256099942544/6300978111` |
| **Interstitial** | `ca-app-pub-3940256099942544/1033173712` |
| **Rewarded** | `ca-app-pub-3940256099942544/5224354917` |
| **Rewarded Interstitial** | `ca-app-pub-3940256099942544/6978759866` |
| **Native** | `ca-app-pub-3940256099942544/2247696110` |

### iOS

| Format | Test ID |
|---|---|
| **App ID** | `ca-app-pub-3940256099942544~1458002511` |
| **Banner** | `ca-app-pub-3940256099942544/2934735716` |
| **Interstitial** | `ca-app-pub-3940256099942544/4411468910` |
| **Rewarded** | `ca-app-pub-3940256099942544/1712485313` |
| **Rewarded Interstitial** | `ca-app-pub-3940256099942544/5354046379` |
| **Native** | `ca-app-pub-3940256099942544/3986624511` |

---

## Ad Index

When configuring `actions` in your JSON, use the following integer index to select which ad network and format to use:

| Index | Ad Network | Format |
|:---:|---|---|
| `0` | Google AdMob | Interstitial |
| `1` | Google AdMob | Rewarded |
| `2` | Google AdMob | Rewarded Interstitial |
| `3` | AppLovin MAX | Interstitial |
| `4` | AppLovin MAX | Rewarded |

---

## License

MIT © [Raj Narola](https://github.com/RajNarola29)
