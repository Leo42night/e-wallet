import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transfer_provider.dart';
import '../widgets/rounded_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final transfer = Provider.of<TransferProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi PIN', style: TextStyle(color: Colors.black)),
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
                subtitle: Text(transfer.selectedContact!.detail),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorText: _error,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            if (transfer.isProcessing) const CircularProgressIndicator(),
            const Spacer(),
            RoundedButton(
              text: 'Konfirmasi',
              enabled: _pinController.text.length == 6 && !transfer.isProcessing,
              onPressed: () async {
                final pin = _pinController.text.trim();
                final ok = await transfer.verifyPin(pin);
                if (!ok) {
                  setState(() => _error = 'PIN salah, coba lagi (hint: 123456)');
                  return;
                }
                // success — show dialog then reset
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Berhasil'),
                    content: const Text('Transfer berhasil (UI-only demo).'),
                    actions: [
                      TextButton(onPressed: () {
                        transfer.resetAll();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }, child: const Text('Selesai'))
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}