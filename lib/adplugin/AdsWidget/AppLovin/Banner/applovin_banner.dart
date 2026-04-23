import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';

class ApplovinBanner extends HookWidget {
  const ApplovinBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoaded = useState<bool>(false);
    final isFailed = useState<bool>(false);

    MainJson mainJson = context.read<MainJson>();

    final adUnitId = mainJson.isTestOn
        ? 'YOUR_APPLOVIN_TEST_BANNER_ID'
        : mainJson.data!['adIds']['applovin']['banner'];

    return SizedBox(
      width: double.infinity,
      height: isLoaded.value ? 50 : 0,
      child: isFailed.value
          ? const SizedBox.shrink()
          : MaxAdView(
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
                },
                onAdClickedCallback: (ad) {},
                onAdExpandedCallback: (ad) {},
                onAdCollapsedCallback: (ad) {},
              ),
            ),
    );
  }
}
