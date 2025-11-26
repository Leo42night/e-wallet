import 'package:e_wallet/services/api_service.dart';
import 'package:e_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:e_wallet/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = _loadData();
  }

  Future<void> _refresh() async {
    // print("REFRESH");
    setState(() {
      futureData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(title: const Text('Recent Transactions')),
      body: FutureBuilder(
        future: futureData,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error atau tidak ada data
          if (!snapshot.hasData || snapshot.data?['success'] != true) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Tidak ada riwayat transaksi')),
                ],
              ),
            );
          }

          // print("snapshot.data: ${snapshot.data}");

          final String userId = snapshot.data!['userId'];
          final List<TransactionModel> transactions =
              snapshot.data!['transactions'];

          // ✅ LANGSUNG RETURN RefreshIndicator + ListView
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final bool isSender = tx.fromId == userId;
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(tx.photoUrl),
                      ),
                      const SizedBox(width: 12),
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
                                  : 'Anda menerima dari ${tx.email}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$sign${formatRupiah(tx.amount)}',
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
            ),
          );
        },
      ),
    );
  }
}

// Ambil list transaksi
Future<Map<String, dynamic>> _loadData() async {
  final api = ApiService();
  final prefs = await SharedPreferences.getInstance();
  final String? currentUserId = prefs.getString('user_id');
  
  // print("currentUserId: $currentUserId");

  if (currentUserId == null) {
    return {
      'success': false,
      'transactions': <TransactionModel>[],
      'error': 'User ID tidak ditemukan',
    };
  }

  final transactionResult = await api.getTransactionHistory(currentUserId);
  // print("transactionResult: $transactionResult");
  // print("transactionResult type: ${transactionResult.runtimeType}");
  // print("success value: ${transactionResult['success']}");
  // print("success type: ${transactionResult['success'].runtimeType}");
  
  // ✅ FIX: Cek apakah 'success' ada dan bernilai true
  if (transactionResult['success'] != true) {
    return {
      'success': false,
      'transactions': <TransactionModel>[],
      'error': transactionResult['error'] ?? 'Gagal memuat data',
    };
  }
  
  // ✅ FIX: Cek tipe data transactions
  final transactions = transactionResult['transactions'];
  List<TransactionModel> transactionList;
  
  if (transactions is List<TransactionModel>) {
    // Sudah berbentuk List<TransactionModel>
    transactionList = transactions;
  } else if (transactions is List) {
    // Masih berbentuk List<Map>, perlu di-convert
    transactionList = transactions
        .map((e) => e is TransactionModel ? e : TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    transactionList = <TransactionModel>[];
  }
  
  // print("Total transactions loaded: ${transactionList.length}");
  
  return {
    'success': true,
    'transactions': transactionList,
    'userId': currentUserId,
  };
}