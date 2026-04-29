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
| 🔔 **OneSignal Push** | Auto-initialised from JSON |
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
