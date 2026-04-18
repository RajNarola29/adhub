
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