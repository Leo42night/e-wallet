import 'package:flutter/material.dart';

class SaldoProvider extends ChangeNotifier {
  bool _isHidden = false;

  bool get isHidden => _isHidden;

  void toggleVisibility() {
    _isHidden = !_isHidden;
    notifyListeners();
  }
}
