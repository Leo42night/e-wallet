import 'package:flutter/material.dart';
import '../models/user.dart';

/// CLASS: TransferProvider
/// FUNGSI: Provider untuk mengelola state transfer uang antar pengguna
/// KEGUNAAN: Menyimpan data transfer (kontak tujuan, nomor, nominal) dan membagikan ke seluruh widget
/// EXTENDS: ChangeNotifier - memungkinkan widget mendengarkan perubahan state
/// TEMPAT DIGUNAKAN: Di TransferMainScreen dan screen-screen terkait transfer
class TransferProvider with ChangeNotifier {
  // ===== PRIVATE STATE VARIABLES =====
  // Variabel ini hanya bisa diakses dalam class ini, akses dari luar via getter

  User? _selectedContact; // Kontak pengguna yang dipilih dari list kontak
  String _enteredNumber =
      ''; // Nomor telepon/email yang diinput manual oleh user
  int? _amount; // Nominal uang yang akan ditransfer
  bool _isProcessing =
      false; // Flag untuk menandakan proses transfer sedang berjalan (untuk loading)

  // ===== PUBLIC GETTERS =====
  // Getter untuk mengakses private variables dari widget lain

  /// GETTER: selectedContact
  /// RETURN: User? - kontak yang dipilih atau null jika belum ada
  User? get selectedContact => _selectedContact;

  /// GETTER: enteredNumber
  /// RETURN: String - nomor/email yang diinput user
  String get enteredNumber => _enteredNumber;

  /// GETTER: amount
  /// RETURN: int? - nominal transfer atau null jika belum ada
  int? get amount => _amount;

  /// GETTER: isProcessing
  /// RETURN: bool - true jika proses transfer sedang berjalan
  bool get isProcessing => _isProcessing;

  // ===== PUBLIC METHODS =====

  /// FUNGSI: selectContact()
  /// TUJUAN: Menandai kontak yang dipilih dari list kontak
  /// PARAMETER: c - User object yang dipilih
  /// AKSI:
  ///   1. Set _selectedContact ke kontak yang dipilih
  ///   2. Auto-fill _enteredNumber dari nomor kontak tersebut
  ///   3. Notify listeners agar UI update
  void selectContact(User c) {
    _selectedContact = c;
    _enteredNumber = c.telp; // Otomatis isi nomor dari kontak
    notifyListeners(); // Beri tahu semua widget yang mendengarkan perubahan
  }

  /// FUNGSI: clearContact()
  /// TUJUAN: Membatalkan pemilihan kontak
  /// AKSI:
  ///   1. Reset _selectedContact ke null
  ///   2. Kosongkan _enteredNumber
  ///   3. Notify listeners agar UI update
  void clearContact() {
    _selectedContact = null;
    _enteredNumber = '';
    notifyListeners();
  }

  /// FUNGSI: setEnteredNumber()
  /// TUJUAN: Update nomor yang diinput user melalui text field
  /// PARAMETER: val - String nomor/email yang diinput
  /// KEGUNAAN: Menangkap input dari TextField saat user mengetik nomor tujuan
  void setEnteredNumber(String val) {
    _enteredNumber = val;
    notifyListeners();
  }

  /// FUNGSI: setAmount()
  /// TUJUAN: Set nominal uang yang akan ditransfer
  /// PARAMETER: value - int nominal dalam rupiah
  /// KEGUNAAN: Menyimpan nominal ketika user input di screen transfer
  void setAmount(int value) {
    _amount = value;
    notifyListeners();
  }

  /// FUNGSI: setProcessing()
  /// TUJUAN: Set flag bahwa proses transfer sedang berjalan
  /// PARAMETER: v - bool true=sedang proses, false=selesai
  /// KEGUNAAN: Untuk menampilkan/menyembunyikan loading indicator
  void setProcessing(bool v) {
    _isProcessing = v;
    notifyListeners();
  }

  /// FUNGSI: setManualNumber()
  /// TUJUAN: Set nomor yang diinput manual (bukan dari kontak)
  /// PARAMETER: number - String nomor yang diinput user
  /// AKSI:
  ///   1. Set _enteredNumber ke nomor yang diinput
  ///   2. Reset _selectedContact ke null (karena nomor diinput manual, bukan dari kontak)
  ///   3. Notify listeners agar UI update
  /// KEGUNAAN: Ketika user mengetik nomor manual, hapus kontak yang sebelumnya dipilih
  void setManualNumber(String number) {
    _enteredNumber = number;
    _selectedContact =
        null; // Reset kontak yang dipilih karena user input manual
    notifyListeners();
  }

  /// FUNGSI: verifyPin()
  /// TUJUAN: Verifikasi PIN user sebelum transfer diproses
  /// PARAMETER: pin - String PIN yang diinput user
  /// RETURN: Future<bool> - true jika PIN benar, false jika salah
  /// AKSI:
  ///   1. Set isProcessing = true (tampilkan loading)
  ///   2. Tunggu 700ms untuk simulasi verifikasi ke server
  ///   3. Set isProcessing = false (selesai loading)
  ///   4. Return hasil: true jika pin == '123456' (mock), false sebaliknya
  /// NOTE: Ini adalah mock/testing. Di production, harus verifikasi ke server
  Future<bool> verifyPin(String pin) async {
    setProcessing(true); // Tampilkan loading indicator
    await Future.delayed(const Duration(milliseconds: 700)); // Simulasi delay
    setProcessing(false); // Sembunyikan loading indicator
    // Simple mock: pin '123456' adalah PIN yang benar
    // Di production, kirim ke server untuk verifikasi
    return pin == '123456';
  }

  /// FUNGSI: resetAll()
  /// TUJUAN: Reset semua state transfer ke nilai default
  /// KEGUNAAN: Dipanggil setelah transfer sukses atau user cancel
  /// AKSI: Reset semua variabel state ke nilai awal
  void resetAll() {
    _selectedContact = null;
    _enteredNumber = '';
    _amount = null;
    _isProcessing = false;
    notifyListeners();
  }
}
