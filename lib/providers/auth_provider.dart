import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _userId = "1"; // placeholder

  String get userId => _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
}