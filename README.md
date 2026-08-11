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
4. **iOS** - enable the "Push Notifications" capability and the "Background Modes > Remote notifications" background mode in Xcode, and upload an APNs auth key (or certificate) to the Firebase console for the app.
5. **iOS image-rich pushes (optional)** - to have notification images render, add a Notification Service Extension target to the app that downloads and attaches the image; FCM alone won't do this on iOS.

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
