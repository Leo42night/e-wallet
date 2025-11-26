// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Ambil token dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Masukkan token ke Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      // ================================
      // SIMPAN KE DATABASE VIA API
      // ================================
      if (user != null) {
        final apiService = ApiService();
        final result = await apiService.loginWithGoogle(user);

        if (result['success']) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString(
              'user_name', user.displayName ?? googleUser.displayName ?? 'User');
          await prefs.setString('user_email', user.email ?? googleUser.email);
          await prefs.setDouble(
            'user_balance',
            double.tryParse(result['user']['balance'] ?? '0') ?? 0.0,
          );
          await prefs.setString('user_id', result['user']['id'] ?? '');
          await prefs.setString('user_photo_url', result['user']['photo_url'] ?? '');
          await prefs.setString('user_telp', result['user']['telp'] ?? '');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          _showError("Gagal menyimpan data ke database: ${result['error']}");
        }
      }
    } catch (e) {
      _showError("Login gagal: $e");
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'E-Wallet',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola keuangan Anda dengan mudah',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _signInWithGoogle,
                              icon: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/google-logo.png',
                                  height: 24,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              label: const Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text(
                      'Dengan masuk, Anda menyetujui\nSyarat & Ketentuan kami',
                      style:
                          TextStyle(fontSize: 12, color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
