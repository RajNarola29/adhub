import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'house_ad_stars.dart';

class HouseBannerAd extends StatelessWidget {
  final Map ad;

  const HouseBannerAd({required this.ad, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7);
    final isIpad = MediaQuery.of(context).size.shortestSide > 600;

    final double iconSize = isIpad ? 60 : 44;
    final double titleFontSize = isIpad ? 19 : 15;
    final double descFontSize = isIpad ? 12 : 10;
    final double starSize = isIpad ? 10 : 8;
    final double btnFontSize = isIpad ? 15 : 12;
    final double brandingSize = isIpad ? 10 : 8;

    final double ratingValue =
        double.tryParse('${ad['rating'] ?? '4.5'}') ?? 4.5;

    return GestureDetector(
      onTap: () {
        final url = '${ad['store_url'] ?? ''}';
        if (url.isEmpty) return;
        try {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } catch (_) {}
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        padding: EdgeInsets.only(
          left: isIpad ? 20 : 16,
          right: isIpad ? 20 : 16,
          top: isIpad ? 12 : 8,
          bottom: isIpad ? 16 : 12,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${ad['name'] ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0182FE,
                          ).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: const Color(0xFF0182FE).withValues(alpha: 0.4),
                            width: 0.5,
                          ),
                        ),
                        child: SvgPicture.asset(
                          isDark
                              ? 'assets/logos/light-logo.svg'
                              : 'assets/logos/dark-logo.svg',
                          height: brandingSize,
                          package: 'adhub',
                        ),
                      ),
                      const SizedBox(width: 3),
                      SvgPicture.asset(
                        isDark
                            ? 'assets/logos/light-name.svg'
                            : 'assets/logos/dark-name.svg',
                        height: brandingSize - 2,
                        package: 'adhub',
                      ),
                      const SizedBox(width: 6),
                      Container(width: 1, height: starSize, color: descColor),
                      const SizedBox(width: 6),
                      ...buildAdStars(ratingValue, starSize),
                      const SizedBox(width: 3),
                      Text(
                        '${ratingValue % 1 == 0 ? ratingValue.toInt() : ratingValue} Ratings',
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ad['description'] ?? ''}',
                    style: TextStyle(fontSize: descFontSize, color: descColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isIpad ? 18 : 14,
                vertical: isIpad ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Platform.isIOS ? 'GET' : 'INSTALL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: btnFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
