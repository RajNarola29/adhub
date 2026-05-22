import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'house_ad_stars.dart';

class HouseNativeAd extends StatelessWidget {
  final Map ad;

  const HouseNativeAd({required this.ad, super.key});

  void _open() {
    final url = '${ad['store_url'] ?? ''}';
    if (url.isEmpty) return;
    try {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7);
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    final isIpad = MediaQuery.of(context).size.shortestSide > 600;

    final double iconSize = isIpad ? 130 : 90;
    final double titleSize = isIpad ? 26 : 20;
    final double starSize = isIpad ? 22 : 18;
    final double ratingTextSize = isIpad ? 14 : 11;
    final double descSize = isIpad ? 17 : 14;
    final double btnHeight = isIpad ? 60 : 48;
    final double btnFontSize = isIpad ? 20 : 16;

    final double ratingValue = double.tryParse('${ad['rating'] ?? '4.5'}') ?? 4.5;
    final String logoAsset = isDark ? 'assets/logos/light-logo.svg' : 'assets/logos/dark-logo.svg';
    final String nameAsset = isDark ? 'assets/logos/light-name.svg' : 'assets/logos/dark-name.svg';

    return DefaultTextStyle(
      style: const TextStyle(inherit: false, decoration: TextDecoration.none),
      child: GestureDetector(
      onTap: _open,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${ad['icon'] ?? ''}',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                cacheWidth: (iconSize * 2).toInt(),
                cacheHeight: (iconSize * 2).toInt(),
                errorBuilder: (_, _, _) => Icon(Icons.apps, size: iconSize),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${ad['name'] ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleSize, color: titleColor),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0182FE).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFF0182FE).withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: SvgPicture.asset(logoAsset, height: 12, package: 'adhub'),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(nameAsset, height: 9, package: 'adhub'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: buildAdStars(ratingValue, starSize)),
                const SizedBox(width: 6),
                Text(
                  '${ratingValue % 1 == 0 ? ratingValue.toInt() : ratingValue} Ratings',
                  style: TextStyle(fontSize: ratingTextSize, color: Colors.amber, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${ad['description'] ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: descSize, color: descColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, btnHeight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _open,
              child: Text(
                Platform.isIOS ? 'GET APP' : 'INSTALL APP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: btnFontSize),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
