import 'package:flutter/material.dart';
import '../models/user.dart';

class TransferProvider with ChangeNotifier {
  User? _selectedContact;
  String _enteredNumber = '';
  int? _amount;
  bool _isProcessing = false;

  User? get selectedContact => _selectedContact;
  String get enteredNumber => _enteredNumber;
  int? get amount => _amount;
  bool get isProcessing => _isProcessing;

  void selectContact(User c) {
    _selectedContact = c;
    _enteredNumber = c.telp;
    notifyListeners();
  }

  void clearContact() {
    _selectedContact = null;
    _enteredNumber = '';
    notifyListeners();
  }

  void setEnteredNumber(String val) {
    _enteredNumber = val;
    notifyListeners();
  }

  void setAmount(int value) {
    _amount = value;
    notifyListeners();
  }

  void setProcessing(bool v) {
    _isProcessing = v;
    notifyListeners();
  }

  void setManualNumber(String number) {
    _enteredNumber = number;
    _selectedContact = null; // buat pastikan kontak yang dipilih di-reset
    notifyListeners();
  }

  // Mock verification for PIN; UI-only here
  Future<bool> verifyPin(String pin) async {
    setProcessing(true);
    await Future.delayed(const Duration(milliseconds: 700));
    setProcessing(false);
    // simple mock: pin == '123456' success
    return pin == '123456';
  }

  // reset after transfer
  void resetAll() {
    _selectedContact = null;
    _enteredNumber = '';
    _amount = null;
    _isProcessing = false;
    notifyListeners();
  }
}