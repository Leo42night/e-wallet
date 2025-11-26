import 'package:e_wallet/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_wallet/providers/transfer_provider.dart';
import 'package:e_wallet/widgets/rounded_button.dart';

class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
    final transfer = Provider.of<TransferProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konfirmasi PIN',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            if (transfer.selectedContact != null)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(transfer.selectedContact!.name),
                subtitle: Text(transfer.selectedContact!.email),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 12),
            const Text('Masukkan PIN transaksi (6 digit)'),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _error,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            if (transfer.isProcessing) const CircularProgressIndicator(),
            const Spacer(),
            RoundedButton(
              text: 'Konfirmasi',
              enabled:
                  _pinController.text.length == 6 && !transfer.isProcessing,
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final currUserId = prefs.getString('user_id') ?? '';
                final pin = _pinController.text.trim();
                final ok = await transfer.verifyPin(pin);
                if (!ok) {
                  setState(
                    () => _error = 'PIN salah, coba lagi (hint: 123456)',
                  );
                  return;
                }
                try {
                  final api = ApiService();
                  final result = await api.transferBalance(
                    from: currUserId,
                    to: transfer.selectedContact!.id,
                    amount: transfer.amount?.toDouble() ?? 0,
                    message: 'Transfer ke ${transfer.selectedContact?.name}',
                  );
                  
                  if (result['success']) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Berhasil'),
                        content: Text("Transfer berhasil $currUserId."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              transfer.resetAll();
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Text('Selesai'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _showError(result['message']);
                  }
                } catch (e) {
                  _showError("Login gagal: $e");
                  print("Error: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
