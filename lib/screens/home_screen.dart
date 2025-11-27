// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:e_wallet/models/transaction.dart';
import 'package:e_wallet/providers/saldo_providers.dart';
import 'package:e_wallet/screens/history.dart';
import 'package:e_wallet/screens/qr/scan_qr_screen.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'package:e_wallet/screens/qr/show_qr_screen.dart';
import 'package:e_wallet/widgets/transfer_main_screen.dart';
import 'package:e_wallet/widgets/action_bar.dart';
import 'package:e_wallet/widgets/mini_action_bar.dart';
import 'package:e_wallet/utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';
  String _userName = '';
  String _userEmail = '';
  double _balance = 0.0;
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email != null) {
      setState(() {
        _userId = prefs.getString('user_id') ?? '';
        _userName = prefs.getString('user_name') ?? '';
        _userEmail = email;
        _balance = prefs.getDouble('user_balance') ?? 0.0;
        _isLoading = false;
      });

      await _refreshFromServer();
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _refreshFromServer() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email != null) {
      final api = ApiService();
      final result = await api.getUserDataByEmail(email);

      if (result['success'] == true && result['user'] != null) {
        final user = result['user'];

        final double newBalance =
            double.tryParse(user['balance'] ?? '0') ?? 0.0;

        if (_balance != newBalance) {
          _showSnackBar("Saldo diperbarui", Colors.green);
        }

        if (mounted) {
          setState(() {
            _balance = newBalance;
            _userName = user['name'] ?? _userName;
          });
        }

        await prefs.setDouble('user_balance', newBalance);
        await prefs.setString('user_name', user['name'] ?? '');
      } else {
        _showSnackBar(
          "Gagal Load Data User: ${result['error']}",
          Colors.orange,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        await prefs.clear();
      }

      final transactionResult = await api.getTransactionHistory(_userId);
      if (transactionResult['success'] == true) {
        setState(
          () => _transactions =
              transactionResult['transactions'] as List<TransactionModel>,
        );
      } else {
        _showSnackBar(
          "Gagal Load Data Transaksi: ${transactionResult['error']}",
          Colors.orange,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(String fitur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur "$fitur" sedang dalam pengembangan'),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Keluar")
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final saldoProv = Provider.of<SaldoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshFromServer,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // HEADER KREM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(color: Color(0xFFF9EFE5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "EasyPay",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Logout
                          GestureDetector(
                            child: const Icon(Icons.logout),
                            onTap: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Hai, $_userName",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                saldoProv.isHidden
                                    ? "••••••••"
                                    : formatRupiah(_balance),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => saldoProv.toggleVisibility(),
                                child: Icon(
                                  saldoProv.isHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black54,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShowQrScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.qr_code_2,
                                color: Colors.black87,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ActionBar(
                        onPindai: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanQrScreen(),
                          ),
                        ),
                        onIsiSaldo: () => _showComingSoon("Isi Saldo"),
                        onKirim: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransferMainScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                QuickActions(
                  onPulsa: () => _showComingSoon("Pulsa"),
                  onPaketData: () => _showComingSoon("Paket Data"),
                  onListrik: () => _showComingSoon("Listrik"),
                  onRiwayat: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // TRANSAKSI
                Container(
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Transaksi Terakhir",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              ),
                              child: Text(
                                "Lihat Selengkapnya",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // KIRIM DATA DARI HOME SCREEN
                      TransactionList(
                        transactions: _transactions,
                        userId: _userId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (i) {
          if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanQrScreen()),
            );
          } else {
            _showComingSoon(
              ["Beranda", "Bayar", "Scan QR", "Notif", "Akun"][i],
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: 30),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.qr_code_scanner, size: 40),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined, size: 30),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: "",
          ),
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String userId;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text("Belum ada transaksi"),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length.clamp(
        0,
        3,
      ), // tampilkan 3 transaksi terbaru
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final amount = tx.amount;
        final isSender = tx.fromId == userId;
        final formattedDate = timeago.format(tx.createdAt);

        return ListTile(
          leading: Icon(
            isSender ? Icons.arrow_upward : Icons.arrow_downward,
            color: isSender ? Colors.red : Colors.green,
          ),
          title: Text(
            "${(isSender ? "Kirim ke" : "Penerima dari")} ${tx.email}",
          ),
          subtitle: Text(formattedDate),
          trailing: Text(
            (isSender ? "-" : "+") + formatRupiah(amount),
            style: TextStyle(
              color: isSender ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}