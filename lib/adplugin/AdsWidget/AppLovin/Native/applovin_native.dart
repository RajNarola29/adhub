import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../MainJson/main_json.dart';
import '../../../Methods/applovin_init.dart';

class ApplovinNative extends HookWidget {
  final VoidCallback onFailed;
  final EdgeInsets margin;

  const ApplovinNative({
    required this.onFailed,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLoaded = useState<bool>(false);
    final isFailed = useState<bool>(false);
    // MaxNativeAdView starts loading as soon as it mounts, so it must not be
    // built until AppLovinMAX.initialize() has actually completed.
    final isSdkReady = useState<bool>(false);

    MainJson mainJson = context.read<MainJson>();

    final String? adUnitId = mainJson.data!['ad_config']['applovin_native'];

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

    // MaxNativeAdView must stay mounted with real constraints to load (its
    // platform view only starts loading once it has a size) - Visibility with
    // maintainState/maintainSize:false keeps it laid out via Offstage while
    // collapsing it to zero space in the surrounding layout until ready,
    // instead of only inserting it into the tree after `onLoaded` like
    // GoogleNative does.
    return Visibility(
      visible: isLoaded.value,
      maintainState: true,
      maintainAnimation: true,
      child: Container(
        margin: margin,
        constraints: const BoxConstraints(minHeight: 270, maxHeight: 402),
        decoration: BoxDecoration(
          color: mainJson.nativeColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: mainJson.nativeBorderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        child: Stack(
          children: [
            MaxNativeAdView(
              adUnitId: adUnitId,
              listener: NativeAdListener(
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MaxNativeAdIconView(width: 40, height: 40),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MaxNativeAdTitleView(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const MaxNativeAdStarRatingView(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Expanded(child: MaxNativeAdMediaView()),
                    const SizedBox(height: 8),
                    const MaxNativeAdBodyView(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: double.infinity,
                      child: MaxNativeAdCallToActionView(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: const Color(0xFFFFCC00),
                child: const Text(
                  'Ad',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
