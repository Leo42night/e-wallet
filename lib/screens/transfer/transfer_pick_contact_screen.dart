// screens/transfer_pick_contact_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../providers/transfer_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/contact_tile.dart';
import 'transfer_amount_screen.dart';

class TransferPickContactScreen extends StatefulWidget {
  const TransferPickContactScreen({super.key});

  @override
  State<TransferPickContactScreen> createState() => _TransferPickContactScreenState();
}

class _TransferPickContactScreenState extends State<TransferPickContactScreen> {
  List<User> contacts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id');

      if (currentUserId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User ID tidak ditemukan';
        });
        return;
      }

      final api = ApiService();
      
      // Get transaction history untuk mendapatkan daftar user yang pernah di-transfer
      // Note: getTransactionHistory menerima parameter (bisa email atau id tergantung backend)
      final transactionResult = await api.getTransactionHistory(currentUserId);

      if (!mounted) return;

      if (transactionResult['success'] == true) {
        final transactions = transactionResult['transactions'] as List<dynamic>? ?? [];
        
        if (transactions.isEmpty) {
          setState(() {
            contacts = [];
            isLoading = false;
          });
          return;
        }
        
        // Ekstrak unique user IDs dari transactions (yang bukan current user)
        final Set<String> uniqueUserIds = {};
        for (var tx in transactions) {
          final fromId = tx['from_id']?.toString() ?? '';
          final toId = tx['to_id']?.toString() ?? '';
          
          // Ambil user yang berlawanan dengan current user
          if (fromId == currentUserId && toId.isNotEmpty) {
            uniqueUserIds.add(toId);
          } else if (toId == currentUserId && fromId.isNotEmpty) {
            uniqueUserIds.add(fromId);
          }
        }

        if (uniqueUserIds.isEmpty) {
          setState(() {
            contacts = [];
            isLoading = false;
          });
          return;
        }

        // Fetch detail user untuk setiap unique ID secara parallel
        final futures = <Future<Map<String, dynamic>>>[];
        for (String userId in uniqueUserIds) {
          futures.add(api.getUserDataById(userId));
        }
        
        final results = await Future.wait(futures);

        List<User> loadedContacts = [];
        for (var result in results) {
          if (result['success'] == true) {
            loadedContacts.add(User.fromJson(result['user'] ?? {}));
          }
        }

        if (!mounted) return;

        setState(() {
          contacts = loadedContacts;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = transactionResult['error'] ?? 'Gagal memuat kontak';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadContacts,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : contacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada kontak',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadContacts,
                            child: const Text('Muat Kontak'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ContactTile(
                          contact: contact,
                          onTap: () {
                            Provider.of<TransferProvider>(context, listen: false)
                                .selectContact(contact);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransferAmountScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}