import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class RateUs {
  Future<void> showRateUsDialog({String fallbackUrl = ''}) async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else if (fallbackUrl.isNotEmpty) {
      // In-app review unavailable (development build, quota exhausted, etc.)
      // Open the store listing directly so the user can still leave a review.
      await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
    }
  }
}
