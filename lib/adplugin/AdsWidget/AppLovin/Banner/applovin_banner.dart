import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';
import '../../../Methods/applovin_init.dart';

class ApplovinBanner extends HookWidget {
  final VoidCallback onFailed;

  const ApplovinBanner({required this.onFailed, super.key});

  @override
  Widget build(BuildContext context) {
    final isLoaded = useState<bool>(false);
    final isFailed = useState<bool>(false);
    // MaxAdView starts loading as soon as it mounts, so it must not be
    // built until AppLovinMAX.initialize() has actually completed.
    final isSdkReady = useState<bool>(false);

    MainJson mainJson = context.read<MainJson>();

    final String? adUnitId = mainJson.data!['ad_config']['applovin_banner'];

    useEffect(() {
      if (adUnitId == null || adUnitId.isEmpty) {
        onFailed();
        return null;
      }
      AppLovinInit.ready.then((_) {
        isSdkReady.value = true;
      });
      return null;
    }, [adUnitId]);

    if (adUnitId == null || adUnitId.isEmpty || isFailed.value) {
      return const SizedBox.shrink();
    }

    if (!isSdkReady.value) {
      return const SizedBox.shrink();
    }

    // MaxAdView (like MaxNativeAdView) only starts loading once it has real
    // layout constraints - it must render at full banner height from the
    // start, not collapse to 0 until isLoaded flips. Gating height on
    // isLoaded made the ad permanently unable to load.
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: MaxAdView(
        adUnitId: adUnitId,
        adFormat: AdFormat.banner,
        listener: AdViewAdListener(
          onAdLoadedCallback: (ad) {
            isLoaded.value = true;
            isFailed.value = false;
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            isLoaded.value = false;
            isFailed.value = true;
            onFailed();
          },
          onAdClickedCallback: (ad) {},
          onAdExpandedCallback: (ad) {},
          onAdCollapsedCallback: (ad) {},
        ),
      ),
    );
  }
}
