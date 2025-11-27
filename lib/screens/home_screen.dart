// screens/home_screen.dart
// IMPORTS: Mengimpor paket dan file yang diperlukan untuk aplikasi e-wallet
import 'package:e_wallet/models/transaction.dart';
import 'package:e_wallet/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart'
    as timeago; // Untuk format waktu relatif (misal: "2 jam yang lalu")
import 'package:provider/provider.dart'; // State management untuk menyimpan dan mengakses state global
import 'package:shared_preferences/shared_preferences.dart'; // Menyimpan data lokal di device
import 'package:google_sign_in/google_sign_in.dart'; // Login dengan Google
import 'package:firebase_auth/firebase_auth.dart'; // Autentikasi Firebase
import '../services/api_service.dart'; // Service untuk komunikasi dengan API backend
import 'auth/login_screen.dart';
import 'package:e_wallet/screens/qr/scan_qr_screen.dart';
import 'package:e_wallet/utils/helpers.dart'; // Helper functions seperti formatRupiah()
import 'package:e_wallet/screens/qr/show_qr_screen.dart';
import 'package:e_wallet/screens/transfer/transfer_main_screen.dart';
import '../providers/saldo_providers.dart'; // Provider untuk mengelola state saldo
import '../widgets/action_bar.dart';
import '../widgets/mini_action_bar.dart';

/// CLASS: HomeScreen - Widget utama layar beranda
/// FUNGSI: Menampilkan dashboard pengguna dengan saldo, riwayat transaksi, dan menu aksi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // STATE VARIABLES: Menyimpan data pengguna dan transaksi yang ditampilkan
  String _userId = ''; // ID unik pengguna dari server
  String _userName = ''; // Nama pengguna
  String _userEmail = ''; // Email pengguna
  double _balance = 0.0; // Saldo dompet digital pengguna
  bool _isLoading =
      true; // Flag untuk menampilkan loading indicator saat startup
  List<TransactionModel> _transactions =
      []; // Daftar riwayat transaksi pengguna

  @override
  void initState() {
    super.initState();
    // LIFECYCLE: Dipanggil saat widget pertama kali dibuat
    // AKSI: Memuat data pengguna dari penyimpanan lokal
    _loadUserData();
  }

  /// FUNGSI: _loadUserData()
  /// TUJUAN: Mengambil data pengguna yang tersimpan di SharedPreferences
  /// ALUR:
  ///   1. Ambil email dari penyimpanan lokal (SharedPreferences)
  ///   2. Jika email ada, load semua data pengguna (ID, nama, email, saldo)
  ///   3. Jika email tidak ada, arahkan ke halaman login
  ///   4. Setelah berhasil, refresh data dari server
  Future<void> _loadUserData() async {
    final prefs =
        await SharedPreferences.getInstance(); // Akses penyimpanan lokal
    final email = prefs.getString(
      'user_email',
    ); // Ambil email dari penyimpanan lokal

    if (email != null) {
      // Data pengguna ditemukan di penyimpanan lokal
      setState(() {
        // Update state dengan data dari penyimpanan lokal
        _userId = prefs.getString('user_id') ?? '';
        _userName = prefs.getString('user_name') ?? '';
        _userEmail = email;
        _balance = prefs.getDouble('user_balance') ?? 0.0;
        _isLoading = false; // Selesai loading
      });

      // Refresh data dari server untuk memastikan data terkini
      await _refreshFromServer();
    } else {
      // Tidak ada email tersimpan = pengguna belum login
      if (mounted) {
        // Arahkan ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  /// FUNGSI: _refreshFromServer()
  /// TUJUAN: Mengambil data terbaru pengguna dan riwayat transaksi dari API backend
  /// ALUR:
  ///   1. Ambil email dari penyimpanan lokal
  ///   2. Panggil API untuk mendapatkan data pengguna terbaru
  ///   3. Bandingkan saldo lama dengan saldo baru, tampilkan notifikasi jika berubah
  ///   4. Simpan data baru ke penyimpanan lokal
  ///   5. Ambil riwayat transaksi dari API
  ///   6. Jika gagal, tampilkan pesan error dan arahkan ke login
  Future<void> _refreshFromServer() async {
    if (!mounted) return; // Cek apakah widget masih aktif

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(
      'user_email',
    ); // Ambil email untuk identifikasi pengguna

    if (email != null) {
      final api = ApiService(); // Inisialisasi API service
      final result = await api.getUserDataByEmail(
        email,
      ); // Panggil API untuk ambil data pengguna

      if (result['success'] == true && result['user'] != null) {
        // API berhasil mengembalikan data
        final user = result['user'];

        // Parse saldo dari string menjadi double (API mengembalikan saldo sebagai string)
        final double newBalance =
            double.tryParse(user['balance'] ?? '0') ?? 0.0;

        // Cek apakah saldo berubah
        if (_balance != newBalance) {
          _showSnackBar(
            "Saldo diperbarui",
            Colors.green,
          ); // Tampilkan notifikasi
        }

        if (mounted) {
          // Update state dengan data terbaru dari server
          setState(() {
            _balance = newBalance;
            _userName = user['name'] ?? _userName;
          });
        }

        // Simpan data terbaru ke penyimpanan lokal untuk akses offline
        await prefs.setDouble('user_balance', newBalance);
        await prefs.setString('user_name', user['name'] ?? '');
      } else {
        // API gagal atau mengembalikan error
        _showSnackBar(
          "Gagal Load Data User: ${result['error']}",
          Colors.orange,
        );
        if (mounted) {
          // Arahkan ke login jika data tidak valid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        await prefs.clear(); // Hapus semua data tersimpan
      }

      // Ambil riwayat transaksi dari API
      final transactionResult = await api.getTransactionHistory(_userId);
      if (transactionResult['success'] == true) {
        // Parse dan simpan riwayat transaksi
        setState(
          () => _transactions =
              transactionResult['transactions'] as List<TransactionModel>,
        );
      } else {
        // Gagal mengambil riwayat transaksi
        _showSnackBar(
          "Gagal Load Data Transaksi: ${transactionResult['error']}",
          Colors.orange,
        );
      }
    }
  }

  /// FUNGSI: _showSnackBar()
  /// TUJUAN: Menampilkan notifikasi di bawah layar (SnackBar)
  /// PARAMETER:
  ///   - message: Pesan yang ditampilkan
  ///   - color: Warna latar belakang notifikasi
  void _showSnackBar(String message, Color color) {
    if (!mounted) return; // Cek apakah widget masih aktif
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2), // Notifikasi ditampilkan 2 detik
      ),
    );
  }

  /// FUNGSI: _showComingSoon()
  /// TUJUAN: Menampilkan notifikasi bahwa fitur belum dikembangkan
  /// DIGUNAKAN: Untuk fitur yang belum diimplementasikan
  void _showComingSoon(String fitur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur "$fitur" sedang dalam pengembangan'),
        backgroundColor: Colors.blue[700],
        behavior:
            SnackBarBehavior.floating, // Notifikasi mengapung di atas widget
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// FUNGSI: _logout()
  /// TUJUAN: Mengeluarkan pengguna dari aplikasi
  /// ALUR:
  ///   1. Tampilkan dialog konfirmasi logout
  ///   2. Jika setuju, hapus semua data lokal dari SharedPreferences
  ///   3. Logout dari Google Sign-In dan Firebase
  ///   4. Arahkan ke halaman login
  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(ctx, false), // Kembali tanpa logout
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), // Konfirmasi logout
            child: const Text("Keluar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Pengguna mengkonfirmasi logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data lokal

      // Logout dari Google Sign-In (ignore error jika belum login via Google)
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      // Logout dari Firebase (ignore error jika belum login via Firebase)
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      if (!mounted) return;
      // Arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // SHOW LOADING: Tampilkan loading indicator jika data masih dimuat
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ambil SaldoProvider untuk mengakses state visibilitas saldo
    final saldoProv = Provider.of<SaldoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          // Pull-to-refresh: Tarik ke bawah untuk refresh data
          onRefresh: _refreshFromServer,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ===== HEADER SECTION (Warna Krem) =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9EFE5),
                  ), // Warna krem
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // APP NAME & LOGOUT BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "EasyPay", // Nama aplikasi
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Tombol logout
                          GestureDetector(
                            child: const Icon(Icons.logout),
                            onTap: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // GREETING: "Hai, [Nama Pengguna]"
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Hai, $_userName", // Nama dari variable state
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

                      // USER EMAIL
                      Text(
                        _userEmail, // Email dari variable state
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),

                      // BALANCE SECTION: Menampilkan saldo dengan tombol visibility toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // SALDO: Tampilkan saldo atau dots jika disembunyikan
                              Text(
                                saldoProv.isHidden
                                    ? "••••••••" // Tersembunyi
                                    : formatRupiah(
                                        _balance,
                                      ), // Terlihat dengan format Rupiah
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // TOGGLE VISIBILITY BUTTON: Tampilkan/sembunyikan saldo
                              GestureDetector(
                                onTap: () => saldoProv.toggleVisibility(),
                                child: Icon(
                                  saldoProv.isHidden
                                      ? Icons
                                            .visibility_off // Ikon mata tertutup
                                      : Icons.visibility, // Ikon mata terbuka
                                  color: Colors.black54,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          // QR CODE BUTTON: Tampilkan QR code untuk menerima pembayaran
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

                      // ACTION BAR: 3 tombol utama (Pindai, Isi Saldo, Kirim)
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

                // ===== QUICK ACTIONS SECTION =====
                // Menu cepat: Pulsa, Paket Data, Listrik, Riwayat
                QuickActions(
                  onPulsa: () => _showComingSoon("Pulsa"),
                  onPaketData: () => _showComingSoon("Paket Data"),
                  onListrik: () => _showComingSoon("Listrik"),
                  onRiwayat: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),

                const SizedBox(height: 15),

                // ===== TRANSACTION HISTORY SECTION =====
                Container(
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      // Header: "Transaksi Terakhir" dan "Lihat Selengkapnya"
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
                            // Tombol "Lihat Selengkapnya" untuk melihat semua transaksi
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

                      // TRANSACTION LIST: Menampilkan list transaksi dari state
                      TransactionList(
                        transactions:
                            _transactions, // Data transaksi dari state
                        userId:
                            _userId, // ID pengguna untuk membedakan pengirim/penerima
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Home adalah tab pertama (index 0)
        onTap: (i) {
          // Handle klik tab
          if (i == 2) {
            // Tab Scan QR (index 2)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanQrScreen()),
            );
          } else {
            // Tab lain masih dalam pengembangan
            _showComingSoon(
              ["Beranda", "Bayar", "Scan QR", "Notif", "Akun"][i],
            );
          }
        },
        items: const [
          // Tab 0: Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: "",
          ),
          // Tab 1: Bayar (Coming Soon)
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: 30),
            label: "",
          ),
          // Tab 2: Scan QR
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.qr_code_scanner, size: 40),
            ),
            label: "",
          ),
          // Tab 3: Notifikasi (Coming Soon)
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined, size: 30),
            label: "",
          ),
          // Tab 4: Akun (Coming Soon)
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: "",
          ),
        ],
      ),
    );
  }
}

/// CLASS: TransactionList
/// FUNGSI: Widget stateless untuk menampilkan daftar transaksi
/// PARAMETER:
///   - transactions: List dari TransactionModel yang akan ditampilkan
///   - userId: ID pengguna untuk menentukan apakah dia pengirim atau penerima
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
    // CEK KOSONG: Jika tidak ada transaksi, tampilkan pesan
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text("Belum ada transaksi"),
        ),
      );
    }

    // DAFTAR TRANSAKSI: Tampilkan maksimal 3 transaksi terbaru
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true, // Ukuran list sesuai isinya
      physics:
          const NeverScrollableScrollPhysics(), // Jangan scroll sendiri, ikuti parent scroll
      itemCount: transactions.length.clamp(0, 3), // Tampilkan max 3 item
      itemBuilder: (context, index) {
        // Ambil data transaksi
        final tx = transactions[index];
        final amount = tx.amount; // Nominal transfer
        final isSender =
            tx.fromId == userId; // Cek apakah pengguna adalah pengirim
        final formattedDate = timeago.format(
          tx.createdAt,
        ); // Format waktu (misal: "2 jam yang lalu")

        return ListTile(
          // LEADING: Ikon penunjuk arah (naik=kirim, turun=terima)
          leading: Icon(
            isSender ? Icons.arrow_upward : Icons.arrow_downward,
            color: isSender
                ? Colors.red
                : Colors.green, // Merah=keluar, Hijau=masuk
          ),
          // TITLE: Email penerima/pengirim
          title: Text(
            "${(isSender ? "Kirim ke" : "Penerima dari")} ${tx.email}",
          ),
          // SUBTITLE: Waktu transaksi dalam format relatif
          subtitle: Text(formattedDate),
          // TRAILING: Nominal dengan tanda +/- dan warna berbeda
          trailing: Text(
            (isSender ? "-" : "+") +
                formatRupiah(
                  amount,
                ), // Negatif untuk kirim, positif untuk terima
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
