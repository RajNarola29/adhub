import 'package:flutter/material.dart';

class MainJson extends ChangeNotifier {
  Map? _data;
  String? _version;
  bool _isAdsOn = true;
  bool _isTestOn = false;
  Color _nativeColor = Colors.white;
  bool _isReviewDialogOpen = false;

  static ValueNotifier<Map?> dataNotifier = ValueNotifier(null);

  Map? get data => _data;

  String? get version => _version;

  bool get isAdsOn => _isAdsOn;

  bool get isTestOn => _isTestOn;

  Color get nativeColor => _nativeColor;

  bool get isReviewDialogOpen => _isReviewDialogOpen;

  set data(Map? value) {
    _data = value;
    dataNotifier.value = value;
    notifyListeners();
  }

  set version(String? value) {
    _version = value;
    notifyListeners();
  }

  set isAdsOn(bool value) {
    _isAdsOn = value;
    notifyListeners();
  }

  set isTestOn(bool value) {
    _isTestOn = value;
    notifyListeners();
  }

  set nativeColor(Color value) {
    _nativeColor = value;
    notifyListeners();
  }

  set isReviewDialogOpen(bool value) {
    _isReviewDialogOpen = value;
    notifyListeners();
  }
}
