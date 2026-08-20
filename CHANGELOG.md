## 0.2.6

* Fix: Android notification tray icon now uses `@drawable/ic_stat_notify_default` instead of `@mipmap/ic_launcher`. Android strips all color from the tray icon and reads only the alpha channel, so a full-color launcher icon rendered as a solid white blob on stock/near-stock Android (confirmed on Motorola) or, on some OEM skins like Samsung One UI, silently fell back to showing the full-color app icon instead - neither is correct. Every consuming app must now provide its own `ic_stat_notify_default` drawable (white silhouette, transparent background, at `drawable-{m,h,xh,xxh,xxxh}dpi`) and a matching `com.google.firebase.messaging.default_notification_icon` meta-data entry in its own `AndroidManifest.xml` - mirrors the convention OneSignal itself used (`ic_stat_onesignal_default`).

## 0.2.5

* Fix: `HouseNativeAd` (the self-promo fallback shown when a Google/AppLovin native ad fails to load) now matches `GoogleNative`/`ApplovinNative` styling - uses `margin ?? MainJson.nativeMargin` (previously a hardcoded `EdgeInsets.all(10)`, ignoring both the app-wide default and any per-slot override) and `MainJson.nativeColor`/`nativeBorderColor` at radius 6 (previously its own theme-brightness-derived colors at radius 12). Intentionally still excludes the "Ad" badge and the 270-402 height constraint used by the other two, since its own icon+title+stars+description+button layout doesn't fit that.
* Fix: `HouseNativeAd`'s title/description text and logo asset could render as white-on-white in a dark-themed app - their light/dark choice was driven by `Theme.of(context).brightness` (the app's ambient theme) instead of the card's actual background color (`MainJson.nativeColor`, which defaults to white independent of app theme). Now derived via `ThemeData.estimateBrightnessForColor(MainJson.nativeColor)` so text always contrasts against the real background.

## 0.2.4

* Fix: `android/build.gradle.kts`'s `kotlinOptions { jvmTarget = ... }` block used the deprecated Kotlin Gradle Plugin DSL, which newer Kotlin/AGP toolchains (as found rolling this out to a consuming app) treat as a hard build error, not just a warning - `flutter build apk` failed entirely with "'var jvmTarget: String' is deprecated". Replaced with the modern `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }` DSL.

## 0.2.3

* Fix: AppLovin interstitial/rewarded/banner loaders no longer crash when `applovin_fullscreen`/`applovin_reward`/`applovin_banner` is missing from an app's remote config - they now fail gracefully via `onFailed()` instead of force-unwrapping a null ad unit ID into the native SDK.
* Feat: AppLovin Native ad support - new `ApplovinNative` widget (`ad_config.applovin_native`), wired into the `NativeAd` dispatcher as `screenConfig['native'] == 1`, alongside the existing Google (`0`) option. Matches `GoogleNative`'s visual styling (`MainJson.nativeColor`/`nativeBorderColor`/`nativeMargin`, rounded border, "Ad" badge) so native ads look identical regardless of which network served them. Falls back to the House Ad system on load failure, same as every other AppLovin/Google ad widget.
* Fix: AppLovin banner/native ad views no longer mount before `AppLovinMAX.initialize()` completes - new `AppLovinInit` (mirroring `GoogleInit`'s `ready` Completer) is now awaited by all 4 AppLovin loaders, fixing an "Attempted to load ad before SDK initialization" failure.
* Fix: `ApplovinBanner` rendered at zero height until its ad loaded, but `MaxAdView` (a platform view) only starts loading once it has real layout constraints - it could never load. Now renders at full banner height as soon as the SDK is ready.
* Chore: adhub is now a real Flutter plugin (was pure-Dart) - added `android/build.gradle.kts` (declares AppLovin/Meta/Unity AdMob mediation adapters + `play-services-ads`), `android/src/main/AndroidManifest.xml`, `android/src/main/kotlin/com/adhub/adhub/AdhubPlugin.kt`, `ios/adhub.podspec` (declares `GoogleMobileAdsMediationAppLovin`/`Facebook`/`Unity` pods, iOS 15.0+), `ios/Classes/AdhubPlugin.swift`, and registered both platforms under `flutter.plugin.platforms` in `pubspec.yaml`. Required so consuming apps' AdMob mediation can actually route to AppLovin/Meta/Unity as bidding/waterfall sources.

## 0.2.2

* Fix: `AdhubFcm.initialize()` and `maybeReRequestPermission()` no longer block app startup - Firebase init, the notification permission prompt, and topic subscriptions used to be awaited before the app's content was shown, adding 1.5-2s to every launch. They now run non-blocking in the background, mirroring the existing `GoogleInit`/`AppLovinMAX` pattern.

## 0.2.1

* Fix: `AdhubFcm.enableNotifications()` and `AdhubNotifications.enableNotifications()` now actually check and request OS notification permission instead of assuming it was already granted - if the OS already refused before, shows adhub's existing settings-deeplink dialog. Both now return `Future<bool>` (previously `Future<void>`) reporting whether the user actually ended up opted in.

## 0.2.0

* Feat: Firebase Cloud Messaging (FCM) support via a new `firebaseOptions` param on `Adhub` - FCM is now the primary push channel, with OneSignal kept installed as a fallback for apps not yet configured with Firebase. Handles topic subscription (broadcast + per-app), foreground/background message display, notification tap deep-linking, and a re-ask flow for denied OS notification permission.
* Feat: Native ad styling is now centralized - `Adhub`/`MainJson` expose `nativeBorderColor` and `nativeMargin` (alongside the existing `nativeColor`), and `GoogleNative` now renders a rounded border plus a unified "Ad" badge overlay for both Android and iOS.
* Feat: `NativeAd` accepts an optional per-call `margin` override on top of the app-wide `MainJson.nativeMargin` default.
* Breaking: `AdhubNotifications.isOptedIn`, `enableNotifications()`, and `disableNotifications()` are now `Future`-based (previously synchronous) since they may need to check/update FCM topic subscription state.
* Fix: `GoogleNative`'s loaded native ad is now disposed on widget unmount - previously leaked native ad memory every time a native ad slot recycled (e.g. inside a `ListView.builder`).
* Chore: Added `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, and `permission_handler` dependencies; upgraded `onesignal_flutter` to ^5.6.7.

## 0.1.3

* Chore: Upgraded dependencies - `dio` to ^5.10.0, `package_info_plus` to ^10.2.0, `onesignal_flutter` to ^5.6.4.

## 0.1.2

* Chore: Upgraded dependencies - `google_mobile_ads` to ^9.0.0, `applovin_max` to ^4.6.4, `app_tracking_transparency` to ^2.0.7, `onesignal_flutter` to ^5.6.2.

## 0.1.1

* Fix: House ad banner and native text styles no longer inherit the host app's theme (shadows, fonts, etc.) — ads now look consistent across all apps.

## 0.1.0

* Feat: House ads system — show your own apps as fallback banner and native ads when real ads fail.
* Feat: SVG branding (logo + name) in house ad widgets with dark/light mode support.
* Fix: Banner and native ads now load correctly on the home screen.
* Fix: Several stability improvements and crash fixes.
* Improvement: All dialogs now support dark and light theme automatically.
* Docs: Added Google AdMob test IDs for Android and iOS to README.

## 0.0.16

* Fix: Implemented Google UMP (User Messaging Platform) consent flow before MobileAds initialization — resolves AdMob "Consent requirement: No CMP" and "Low coverage" policy violations.
* Fix: ATT (App Tracking Transparency) on iOS now runs before UMP consent and MobileAds init — correct order per Google's guidelines.
* Chore: Removed duplicate ATT request from the post-init callback; ATT is now handled exclusively in `BaseClass.initAdNetworks`.
* Fix: OneSignal notification permission is now requested only once — if the user taps "Don't Allow", the prompt will not appear again on subsequent launches.
* Fix: Tapping "Rate" on Android now opens the Play Store listing directly when the in-app review API is unavailable (debug build, quota exhausted, etc.).

## 0.0.15

* Fix: App Tracking Transparency (ATT) dialog now reliably appears on the very first launch on iOS.
* Fix: ATT request is now made **before** OneSignal notification permission to avoid iOS silently dropping the dialog when two system permission prompts collide.
* Fix: Added `trackingAuthorizationStatus` check — ATT is only requested when status is `notDetermined`, preventing unnecessary calls on subsequent launches.
* Improvement: Added a 500ms settle delay before presenting the ATT dialog to ensure the root view is fully rendered when iOS shows the prompt.

## 0.0.14

* Refactor: Extracted all dialog UI definitions into a centralized utility class `AdhubDialogs` to improve maintainability and reduce main file size.
* Optimization: Replaced legacy inline dialog functions with clean calls to static utility methods.

## 0.0.13

* Documentation: Simplified README and updated installation instructions.
* Fix: Quick fixes and stability improvements.

## 0.0.12

* Removed unused `get` package dependency to reduce package size.

## 0.0.11

* Cleaned up console output by removing unnecessary `print()`, `debugPrint()`, and `Logger` statements throughout the package.
* Removed `logger` package dependency.
* Upgraded dependencies to latest versions (`google_mobile_ads: ^8.0.0`, `package_info_plus: ^10.1.0`, `onesignal_flutter: ^5.5.1`).

## 0.0.10

* Fix: Added `GoogleInit.ready` Completer — all Google ad loaders now await AdMob init before loading. Splash screen ads now work correctly with non-blocking startup.

## 0.0.9

* Performance: `MobileAds.instance.initialize()` is now non-blocking to eliminate 2-3 second startup delay caused by waiting for all mediation adapters (including AppLovin) to finish.

## 0.0.8

* Performance: `AppLovinMAX.initialize()` is now non-blocking (fire-and-forget) to eliminate 4-5 second startup delay.
* Fix: Added null-safe `?? false` check on `appLovin` ad network flag to prevent crashes when the key is missing.

## 0.0.7


* Hotfix: Prevented a crash inside `initAdNetworks` by checking the app version and checking for forced update explicitly before execution.

## 0.0.6

* Hotfix: resolved a compilation error by ensuring `<bool>` return type safety on OneSignal's `isOptedIn` method.

## 0.0.5

* Added fallback logic to show the update dialog with `appUrl` if the specified app version isn't found in JSON.
* Optimized `RateUs` dialog to not repeatedly show in the same session after the user interacts with it.
* Added `AdhubNotifications` utility class to easily allow developers to toggle OneSignal push notifications on and off for the end-user.
* Upgraded underlying package dependencies to the newest stable versions.

## 0.0.4

* Major refactor of `Ads` singleton (reduced 1200+ lines of duplicate code).
* Unified ad type indexing (0: Google Inter, 1: Google Rewarded, 2: Google Rewarded Inter, 3: AppLovin Inter, 4: AppLovin Rewarded).
* Added AppLovin Rewarded ad support.
* Added descriptive logging for ad lifecycle events.
* Removed `GlobalBannerAd` (logic unified into screen-level banners).

## 0.0.3

* Added multi-platform support (Android & iOS).
* Stability improvements and bug fixes.

## 0.0.2

* TODO: quick fixes.

## 0.0.1

* TODO: Describe initial release.