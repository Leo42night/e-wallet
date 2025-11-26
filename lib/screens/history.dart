import 'package:e_wallet/services/api_service.dart';
import 'package:e_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:e_wallet/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WIDGET LIST RIWAYAT TRANSAKSI
class TransactionHistoryList extends StatelessWidget {
  final String userId;
  final List<TransactionModel> transactions;

  const TransactionHistoryList({
    super.key,
    required this.userId,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: transactions.length,
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];

        final bool isSender = tx.fromId == userId;
        final bool isReceiver = tx.toId == userId;

        // Kalau bukan sender & bukan receiver (data aneh) bisa di-skip / ditandai
        final String sign = isSender ? '-' : '+';
        final Color amountColor = isSender ? Colors.red : Colors.green;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Avatar profil (dari from_id atau to_id, di sini pakai profileUrl yang sudah dipilih di backend)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(tx.photoUrl),
              ),
              const SizedBox(width: 12),

              // Pesan / keterangan transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSender
                          ? 'Anda mengirim ke ${tx.email}'
                          : isReceiver
                          ? 'Anda menerima dari ${tx.email}'
                          : 'Transaksi lain',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Nominal dengan + / -
              Text(
                'Rp$sign${formatRupiah(tx.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

/// PAKAI DI HALAMAN
class _HistoryScreenState extends State<HistoryScreen> {
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _loadData();
  }

  Future<void> _refresh() async {
    print("REFRESH");
    setState(() {
      futureData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(title: const Text('Recent Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            // handle async
            future: futureData,
            builder: (context, snapshot) {
              // loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data?['success'] != true) {
                return const Center(child: Text('Tidak ada riwayat transaksi'));
              }

              // Ambil data (!=crash jika null)
              final String userId = snapshot.data!['userId'];
              final List<TransactionModel> transactions =
                snapshot.data!['transactions'];
                
              return ListView(
              physics: const AlwaysScrollableScrollPhysics(), // ✔️ wajib
              padding: const EdgeInsets.all(16),
              children: [
                TransactionHistoryList(
                  userId: userId,
                  transactions: transactions,
                )
              ],
            );
            },
          ),
        ),
      ),
    );
  }
}

// ambil list transaksi
Future<Map<String, dynamic>> _loadData() async {
  final api = ApiService();

  // Ambil user id dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? currentUserId = prefs.getString('user_id');
  print("currentUserId: $currentUserId");

  if (currentUserId == null) {
    return {
      'success': false,
      'transactions': [],
      'error': 'User ID tidak ditemukan',
    };
  }

  // Ambil data transaksi dari API
  final transactions = await api.getTransactionHistory(currentUserId);
  print("transactions: $transactions");

  return {
    'success': true,
    'transactions': transactions,
    'userId': currentUserId,
  };
}
