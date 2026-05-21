import 'package:flutter/material.dart';

List<Widget> buildAdStars(double rating, double size) {
  final int full = rating.floor();
  final bool half = (rating - full) >= 0.5;
  final int empty = 5 - full - (half ? 1 : 0);
  return [
    ...List.generate(full, (_) => Icon(Icons.star_rounded, color: Colors.amber, size: size)),
    if (half) Icon(Icons.star_half_rounded, color: Colors.amber, size: size),
    ...List.generate(empty, (_) => Icon(Icons.star_outline_rounded, color: Colors.amber, size: size)),
  ];
}
