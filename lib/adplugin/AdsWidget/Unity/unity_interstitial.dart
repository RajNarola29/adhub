// // 🐦 Flutter imports:
// import 'package:flutter/cupertino.dart';
//
// // 📦 Package imports:
// import 'package:provider/provider.dart';
// import 'package:unity_ads_plugin/unity_ads_plugin.dart';
//
// // 🌎 Project imports:
// import '../../MainJson/MainJson.dart';
//
// class UnityInterstitial {
//   void loadAd(
//       {required BuildContext context,
//       required Function() onLoaded,
//       required Function() onComplete,
//       required Function() onFailed}) {
//     MainJson mainJson = context.read<MainJson>();
//     print("unity called");
//     UnityAds.load(
//       placementId: '${mainJson.data!['adIds']['unity']['placementId']}',
//       onComplete: (placementId) {
//         onLoaded();
//         UnityAds.showVideoAd(
//           placementId: '${mainJson.data!['adIds']['unity']['placementId']}',
//           onStart: (placementId) {
//             print("unity started");
//           },
//           onClick: (placementId) {},
//           onSkipped: (placementId) {
//             onComplete();
//           },
//           onComplete: (placementId) {
//             onComplete();
//           },
//           onFailed: (placementId, error, message) {
//             print("unity failed ---");
//             onFailed();
//           },
//         );
//       },
//       onFailed: (placementId, error, message) {},
//     );
//   }
// }
