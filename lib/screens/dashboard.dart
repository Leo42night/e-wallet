import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/saldo_providers.dart';
import '../widgets/action_bar.dart';
import '../widgets/mini_action_bar.dart';
import '../widgets/mini_history.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String fitur) {
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
    final saldoProv = Provider.of<SaldoProvider>(context);
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                  const Text(
                    "EasyPay",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hai, Elga",
                    style: TextStyle(fontSize: 20, color: Colors.black87),
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
                            : rupiah.format(5000000),
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
                    onPindai: () => _showComingSoon(context, "Pindai"),
                    onIsiSaldo: () => _showComingSoon(context, "Isi Saldo"),
                    onKirim: () => _showComingSoon(context, "Kirim"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            QuickActions(
              onPulsa: () => _showComingSoon(context, "Pulsa"),
              onPaketData: () => _showComingSoon(context, "Paket Data"),
              onListrik: () => _showComingSoon(context, "Listrik"),
              onRiwayat: () => _showComingSoon(context, "Riwayat"),
            ),

            const SizedBox(height: 15),

            // TRANSAKSI
            Expanded(
              child: Container(
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
                                _showComingSoon(context, "Lihat Selengkapnya"),
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
                    const Expanded(child: TransactionList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (i) => _showComingSoon(
          context,
          ["Beranda", "Bayar", "Scan QR", "Notif", "Akun"][i],
        ),
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
  const TransactionList({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        TransactionItem(
          icon: Icons.arrow_upward,
          title: "Mengirim ke Fuad",
          date: "22 Nov 2025",
          amount: "-Rp2.300",
          color: Colors.red,
        ),
        TransactionItem(
          icon: Icons.add,
          title: "Isi Saldo",
          date: "08 Sep 2025",
          amount: "+Rp25.000",
          color: Colors.green,
        ),
        TransactionItem(
          icon: Icons.phone_iphone,
          title: "Membeli Pulsa",
          date: "03 Sep 2025",
          amount: "-Rp10.000",
          color: Colors.red,
        ),
      ],
    );
  }
}
