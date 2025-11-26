import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'package:e_wallet/screens/qr/scan_qr_screen.dart';
import 'package:e_wallet/screens/qr/show_qr_screen.dart';
import 'package:e_wallet/screens/transfer/transfer_main_screen.dart';
import '../providers/saldo_providers.dart';
import '../widgets/action_bar.dart';
import '../widgets/mini_action_bar.dart';
import '../widgets/mini_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userPhotoUrl = '';
  String _userTelp = '';
  double _balance = 0.0;
  bool _isLoading = true;
  bool _isRefreshing = false;

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
        _userName = prefs.getString('user_name') ?? '';
        _userEmail = email;
        _userPhotoUrl = prefs.getString('user_photo_url') ?? '';
        _userTelp = prefs.getString('user_telp') ?? '';
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
    setState(() => _isRefreshing = true);

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
        _showSnackBar("Gagal Load Data User: ${result['error']}", Colors.orange);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        await prefs.clear();
      }
    }

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
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
            child: const Text("Keluar"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final saldoProv = Provider.of<SaldoProvider>(context);
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ShowQrScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Hai, $_userName",
                              style: const TextStyle(fontSize: 20, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Saldo anda saat ini",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            saldoProv.isHidden
                                ? "••••••••"
                                : rupiah.format(_balance),
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
                      const SizedBox(height: 20),
                      ActionBar(
                        onPindai: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                        ),
                        onIsiSaldo: () => _showComingSoon("Isi Saldo"),
                        onKirim: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransferMainScreen()),
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
                  onRiwayat: () => _showComingSoon("Riwayat"),
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
                              onTap: () =>
                                  _showComingSoon("Lihat Selengkapnya"),
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
                      const TransactionList(),
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
            _showComingSoon(["Beranda", "Bayar", "Scan QR", "Notif", "Akun"][i]);
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

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id');

      if (currentUserId == null) {
        setState(() => isLoading = false);
        return;
      }

      final api = ApiService();
      final Map<String, String> userNameCache = {};

      // Ambil transaksi
      final result = await api.getTransactionHistory(currentUserId);

      if (!mounted) return;

      if (result['success'] == true) {
        final txList = result['transactions'] as List<dynamic>? ?? [];

        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
        final filteredTx = <Map<String, dynamic>>[];

        for (var tx in txList) {
          final txMap = Map<String, dynamic>.from(tx);
          final createdAtStr = txMap['created_at']?.toString() ?? '';

          DateTime? txDate = DateTime.tryParse(createdAtStr);
          if (txDate == null) continue;

          if (txDate.isAfter(oneWeekAgo)) {
            filteredTx.add(txMap);
          }
        }

        filteredTx.sort((a, b) {
          final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });

        for (var tx in filteredTx) {
          final fromId = tx['from_id']?.toString() ?? '';
          final toId = tx['to_id']?.toString() ?? '';

          if (fromId.isNotEmpty && !userNameCache.containsKey(fromId)) {
            final userData = await api.getUserDataById(fromId);
            if (userData['success'] == true) {
              userNameCache[fromId] = userData['user']['name'] ?? 'Unknown';
            }
          }

          if (toId.isNotEmpty && !userNameCache.containsKey(toId)) {
            final userData = await api.getUserDataById(toId);
            if (userData['success'] == true) {
              userNameCache[toId] = userData['user']['name'] ?? 'Unknown';
            }
          }

          tx['from_name'] = userNameCache[fromId] ?? 'Unknown';
          tx['to_name'] = userNameCache[toId] ?? 'Unknown';
        }

        setState(() {
          transactions = filteredTx.take(3).toList();
          isLoading = false;
        });

      } else {
        setState(() => isLoading = false);
      }

    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Belum ada transaksi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final fromId = tx['from_id']?.toString() ?? '';
        final toId = tx['to_id']?.toString() ?? '';
        final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
        final createdAt = tx['created_at']?.toString() ?? '';
        
        // Parse date
        DateTime txDate;
        try {
          txDate = DateTime.parse(createdAt);
        } catch (_) {
          txDate = DateTime.now();
        }
        
        final formattedDate = '${txDate.day} ${_getMonthName(txDate.month)} ${txDate.year}';

        // Dari SharedPreferences, ambil current user ID
        // Jika user adalah pengirim, tampilkan sebagai pengeluaran (merah)
        // Jika user adalah penerima, tampilkan sebagai pemasukan (hijau)
        
        return FutureBuilder<String?>(
          future: SharedPreferences.getInstance().then((prefs) => prefs.getString('user_id')),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            
            final currentUserId = snapshot.data;
            final isSender = fromId == currentUserId;
            
            return TransactionItem(
              icon: isSender ? Icons.arrow_upward : Icons.arrow_downward,
              title: isSender
                  ? 'Mengirim ke ${tx['to_name']}'
                  : 'Menerima dari ${tx['from_name']}',
              date: formattedDate,
              amount: isSender
                  ? '-Rp${amount.toStringAsFixed(0)}'
                  : '+Rp${amount.toStringAsFixed(0)}',
              color: isSender ? Colors.red : Colors.green,
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
