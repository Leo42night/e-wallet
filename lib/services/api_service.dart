// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // PENTING: Ganti dengan URL backend Anda
  // Untuk testing lokal:
  // - Android Emulator: http://10.0.2.2:3000/api
  // - iOS Simulator: http://localhost:3000/api
  // - Real Device: http://YOUR_COMPUTER_IP:3000/api (contoh: http://192.168.1.100:3000/api)
  // Untuk production: https://your-domain.com/api
  
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Default untuk Android Emulator
  static const String baseUrl = 'http://192.168.1.10:3000/api'; // Default untuk Android Emulator
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Login atau register user dengan Google OAuth
  /// Mengirim nama dan email ke backend
  /// Backend akan create user baru atau return user existing
  Future<Map<String, dynamic>> loginWithGoogle({
    required String name,
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
            }),
          )
          .timeout(timeoutDuration);

      print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("DECODED: $data");
        return {
          'success': true,
          'user': data['user'],
          'message': 'Login berhasil',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': 'Data tidak valid',
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'error': 'Server error, coba lagi nanti',
        };
      } else {
        return {
          'success': false,
          'error': 'Error: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet',
      };
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Gagal terhubung ke server',
      };
    } on FormatException {
      return {
        'success': false,
        'error': 'Format response tidak valid',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // sign Up with username/email and password

  /// Get user data berdasarkan email
  /// Digunakan untuk refresh balance dan data user
  Future<Map<String, dynamic>> getUserData(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/$encodedEmail'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      print("RAW RESPONSE (USER): ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("DECODED (USER): $data");
        return {
          'success': true,
          'user': data['user'],
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'User tidak ditemukan',
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'error': 'Server error',
        };
      } else {
        return {
          'success': false,
          'error': 'Error: ${response.statusCode}',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet',
      };
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Gagal terhubung ke server',
      };
    } on FormatException {
      return {
        'success': false,
        'error': 'Format response tidak valid',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Update balance user (untuk fitur top up)
  Future<Map<String, dynamic>> updateBalance({
    required String email,
    required double amount,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/user/balance'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'amount': amount,
            }),
          )
          .timeout(timeoutDuration);

      print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("DECODED: $data");

        return {
          'success': true,
          'user': data['user'],
          'message': 'Balance berhasil diupdate',
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal update balance',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet',
      };
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Gagal terhubung ke server',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Transfer balance antar user
  Future<Map<String, dynamic>> transferBalance({
    required String fromEmail,
    required String toEmail,
    required double amount,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/transaction/transfer'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'from_email': fromEmail,
              'to_email': toEmail,
              'amount': amount,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Transfer berhasil',
          'transaction': data['transaction'],
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Transfer gagal',
        };
      } else {
        return {
          'success': false,
          'error': 'Transfer gagal',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet',
      };
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Gagal terhubung ke server',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Get transaction history
  Future<Map<String, dynamic>> getTransactionHistory(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final response = await http
          .get(
            Uri.parse('$baseUrl/transaction/history/$encodedEmail'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'transactions': data['transactions'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal mengambil riwayat transaksi',
          'transactions': [],
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Tidak ada koneksi internet',
        'transactions': [],
      };
    } on http.ClientException {
      return {
        'success': false,
        'error': 'Gagal terhubung ke server',
        'transactions': [],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: ${e.toString()}',
        'transactions': [],
      };
    }
  }

  /// Helper method untuk cek koneksi ke server
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Helper method untuk format error message
  String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Tidak ada koneksi internet';
    } else if (error is http.ClientException) {
      return 'Gagal terhubung ke server';
    } else if (error is FormatException) {
      return 'Format data tidak valid';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }
}