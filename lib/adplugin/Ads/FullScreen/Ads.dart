import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../AdLoader/ad_loader_provider.dart';
import '../../AdsWidget/AppLovin/Interstitial/applovin_interstitial.dart';
import '../../AdsWidget/AppLovin/Rewarded/applovin_rewarded.dart';
import '../../AdsWidget/Google/Interstitial/google_interstitial.dart';
import '../../AdsWidget/Google/Rewarded Interstitial/google_rewarded_interstitial.dart';
import '../../AdsWidget/Google/Rewarded/google_rewarded.dart';
import '../../MainJson/main_json.dart';

// Ad-type index constants (from remote JSON):
// 0 = Google Interstitial       | 1 = Google Rewarded
// 2 = Google Rewarded Inter     | 3 = AppLovin Interstitial
// 4 = AppLovin Rewarded

class Ads {
  static final Ads _singleton = Ads._internal();

  factory Ads() => _singleton;

  Ads._internal();

  Map routeIndex = {};
  int currentAdIndex = 0;
  int failCounter = 0;
  Timer? timer;

  // ── Index / loop helpers ───────────────────────────────────────────────────

  void indexIncrement(String? key, int maxIndex) {
    failCounter = 0;
    if (key != null) {
      routeIndex[key] = (routeIndex[key] == null)
          ? (maxIndex == 0 ? 0 : 1)
          : (routeIndex[key] < maxIndex ? routeIndex[key] + 1 : 0);
    } else {
      currentAdIndex = currentAdIndex < maxIndex ? currentAdIndex + 1 : 0;
    }
  }

  bool loopBreaker(int maxRetry) {
    if (failCounter < maxRetry) {
      failCounter++;
      return false;
    }
    failCounter = 0;
    return true;
  }

  // ── Core ad dispatcher ────────────────────────────────────────────────────

  void _dispatchAd({
    required int adTypeIndex,
    required BuildContext context,
    required VoidCallback onLoaded,
    required VoidCallback onComplete,
    required VoidCallback onFailed,
  }) {
    switch (adTypeIndex) {
      case 0:
        GoogleInterstitial().loadAd(
          context: context,
          onLoaded: onLoaded,
          onComplete: onComplete,
          onFailed: onFailed,
        );
      case 1:
        GoogleRewarded().loadAd(
          context: context,
          onLoaded: onLoaded,
          onComplete: onComplete,
          onFailed: onFailed,
        );
      case 2:
        GoogleRewardedInterstitial().loadAd(
          context: context,
          onLoaded: onLoaded,
          onComplete: onComplete,
          onFailed: onFailed,
        );
      case 3:
        ApplovinInterstitial().loadAd(
          context: context,
          onLoaded: onLoaded,
          onComplete: onComplete,
          onFailed: onFailed,
        );
      case 4:
        ApplovinRewarded().loadAd(
          context: context,
          onLoaded: onLoaded,
          onComplete: onComplete,
          onFailed: onFailed,
        );
      default:
        onComplete();
    }
  }

  // ── Unified show flow ─────────────────────────────────────────────────────
  // All three show* methods resolve their JSON config and delegate here.

  void _resolveAndShow({
    required BuildContext context,
    required String?
    key, // routeIndex key (route, actionName, or "route/action")
    required List localClick,
    required Map? localFail,
    required int maxFailed,
    required VoidCallback onComplete,
  }) {
    final mainJson = context.read<MainJson>();
    final loaderProvider = context.read<AdLoaderProvider>();
    final int index = key != null ? (routeIndex[key] ?? 0) : currentAdIndex;
    final int adTypeIndex = localClick[index];
    final int listMax = localClick.length - 1;

    // Cooldown: fire onComplete if ad hasn't loaded within overrideTimer seconds.
    final int timeout = mainJson.data?['version_config']?[mainJson.version]?['globalConfig']?['overrideTimer'] ?? 30;
    timer = Timer.periodic(
      Duration(seconds: timeout),
      (t) {
        loaderProvider.isAdLoading = false;
        onComplete();
        t.cancel();
      },
    );

    _dispatchAd(
      adTypeIndex: adTypeIndex,
      context: context,
      onLoaded: () => timer?.cancel(),
      onComplete: () {
        indexIncrement(key, listMax);
        loaderProvider.isAdLoading = false;
        timer?.cancel();
        onComplete();
      },
      onFailed: () => _retryAd(
        context: context,
        from: adTypeIndex,
        key: key,
        listMax: listMax,
        localFail: localFail,
        maxFailed: maxFailed,
        onComplete: () {
          loaderProvider.isAdLoading = false;
          timer?.cancel();
          onComplete();
        },
      ),
    );
  }

  void _retryAd({
    required BuildContext context,
    required int from,
    required String? key,
    required int listMax,
    required Map? localFail,
    required int maxFailed,
    required VoidCallback onComplete,
  }) {
    if (localFail?[from.toString()] == null) {
      onComplete();
      return;
    }
    if (loopBreaker(maxFailed)) {
      onComplete();
      return;
    }

    final int fallback = localFail![from.toString()];
    _dispatchAd(
      adTypeIndex: fallback,
      context: context,
      onLoaded: () => timer?.cancel(),
      onComplete: () {
        indexIncrement(key, listMax);
        timer?.cancel();
        onComplete();
      },
      onFailed: () => _retryAd(
        context: context,
        from: fallback,
        key: key,
        listMax: listMax,
        localFail: localFail,
        maxFailed: maxFailed,
        onComplete: () {
          timer?.cancel();
          onComplete();
        },
      ),
    );
  }

  // ── Guard helper ──────────────────────────────────────────────────────────

  bool _blocked(MainJson m, AdLoaderProvider l, VoidCallback onComplete) {
    final v = m.data?['version_config']?[m.version];
    if (!m.isAdsOn || (v?['globalConfig']?['globalAdFlag'] ?? false) == false) {
      l.isAdLoading = false;
      onComplete();
      return true;
    }
    return false;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  void showFullScreen({
    required BuildContext context,
    required VoidCallback onComplete,
  }) {
    final mainJson = context.read<MainJson>();
    final loaderProvider = context.read<AdLoaderProvider>();
    final String? route = ModalRoute.of(context)?.settings.name;
    loaderProvider.isAdLoading = true;

    if (_blocked(mainJson, loaderProvider, onComplete)) return;
    final v = mainJson.data?['version_config']?[mainJson.version];
    final screenConfig = v?['screens']?[route];

    if (screenConfig == null || (screenConfig['localAdFlag'] ?? false) == false) {
      loaderProvider.isAdLoading = false;
      onComplete();
      return;
    }

    _resolveAndShow(
      context: context,
      key: route,
      localClick: screenConfig['localClick'] ?? [],
      localFail: screenConfig['localFail'] ?? {},
      maxFailed: v?['globalConfig']?['maxFailed'] ?? 0,
      onComplete: onComplete,
    );
  }

  void showActionBasedAds({
    required BuildContext context,
    required String actionName,
    required VoidCallback onComplete,
  }) {
    final mainJson = context.read<MainJson>();
    final loaderProvider = context.read<AdLoaderProvider>();
    loaderProvider.isAdLoading = true;

    if (_blocked(mainJson, loaderProvider, onComplete)) return;
    final v = mainJson.data?['version_config']?[mainJson.version];
    final actionConfig = v?['actions']?[actionName];

    if (actionConfig == null || (actionConfig['localAdFlag'] ?? false) == false) {
      loaderProvider.isAdLoading = false;
      onComplete();
      return;
    }

    _resolveAndShow(
      context: context,
      key: actionName,
      localClick: actionConfig['localClick'] ?? [],
      localFail: actionConfig['localFail'] ?? {},
      maxFailed: v?['globalConfig']?['maxFailed'] ?? 0,
      onComplete: onComplete,
    );
  }

  void showScreenActionBasedAds({
    required BuildContext context,
    required String actionName,
    required VoidCallback onComplete,
  }) {
    final mainJson = context.read<MainJson>();
    final loaderProvider = context.read<AdLoaderProvider>();
    final String? route = ModalRoute.of(context)?.settings.name;
    loaderProvider.isAdLoading = true;

    if (_blocked(mainJson, loaderProvider, onComplete)) return;
    final v = mainJson.data?['version_config']?[mainJson.version];
    final screenConfig = v?['screens']?[route];
    final actionConfig = screenConfig?['actions']?[actionName];

    if (screenConfig == null || (screenConfig['localAdFlag'] ?? false) == false ||
        actionConfig == null || (actionConfig['localAdFlag'] ?? false) == false) {
      loaderProvider.isAdLoading = false;
      onComplete();
      return;
    }

    _resolveAndShow(
      context: context,
      key: '$route/$actionName',
      localClick: actionConfig['localClick'] ?? [],
      localFail: actionConfig['localFail'] ?? {},
      maxFailed: v?['globalConfig']?['maxFailed'] ?? 0,
      onComplete: onComplete,
    );
  }
}
