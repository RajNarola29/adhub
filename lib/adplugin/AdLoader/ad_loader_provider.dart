import 'package:flutter/material.dart';

class AdLoaderProvider extends ChangeNotifier {
  bool _isAdLoading = false;

  bool get isAdLoading => _isAdLoading;

  set isAdLoading(bool value) {
    _isAdLoading = value;
    notifyListeners();
  }
}
