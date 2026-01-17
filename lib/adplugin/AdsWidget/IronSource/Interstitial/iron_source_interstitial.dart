// // 🐦 Flutter imports:
// import 'package:flutter/cupertino.dart';
//
// // 📦 Package imports:
// import 'package:ironsource_adpluginx/ironsource_adpluginx.dart';
//
// // class IronSourceInterstitial {
// //
// //  void loadAd(
// //       {required BuildContext context,
// //       required Function() onComplete,
// //       required Function() onFailed}) {
// //     IronSourceFullScreen ironSourceFullScreen =
// //         IronSourceFullScreen.onInit(onComplete: () {
// //       onComplete();
// //     }, onFailed: () {
// //           print("failed ironsource");
// //
// //       onFailed();
// //     });
// //     IronSource.setISListener(ironSourceFullScreen);
// //     IronSource.loadInterstitial();
// //   }
// // }
//
// class IronSourceFullScreenX with LevelPlayInterstitialListener {
//   Function() onComplete;
//   Function() onFailed;
//   Function() onLoaded;
//
//   IronSourceFullScreenX.onInit(
//       {required this.onComplete, required this.onFailed,required this.onLoaded});
//
//
//
//   @override
//   void onAdClicked(IronSourceAdInfo adInfo) {
//   }
//
//   @override
//   void onAdClosed(IronSourceAdInfo adInfo) {
// onComplete();  }
//
//   @override
//   void onAdLoadFailed(IronSourceError error) {
//     print(error);
//     onFailed();
//     print("ON Load Failtd");
//   }
//
//   @override
//   void onAdOpened(IronSourceAdInfo adInfo) {
//     // TODO: implement onAdOpened
//   }
//
//   @override
//   void onAdReady(IronSourceAdInfo adInfo) {
//      onLoaded();
//    }
//
//   @override
//   void onAdShowFailed(IronSourceError error, IronSourceAdInfo adInfo) {
//    onFailed();
//   }
//
//   @override
//   void onAdShowSucceeded(IronSourceAdInfo adInfo) {
//     // TODO: implement onAdShowSucceeded
//   }
//
//
// }
