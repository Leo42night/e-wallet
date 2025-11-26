// screens/transfer_confirm_pin_screen.dart
import 'package:e_wallet/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/transfer_provider.dart';

class TransferConfirmPinScreen extends StatefulWidget {
  final String note;
  const TransferConfirmPinScreen({super.key, required this.note});

  @override
  State<TransferConfirmPinScreen> createState() =>
      _TransferConfirmPinScreenState();
}

class _TransferConfirmPinScreenState extends State<TransferConfirmPinScreen> {
  String pin = '';

  @override
  Widget build(BuildContext context) {
    final transfer = Provider.of<TransferProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Masukkan PIN'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < pin.length ? Colors.black : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 60),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(30),
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.4,
              children: [
                ...[
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                ].map((d) => _pinButton(d)),
                const SizedBox(),
                _pinButton('0'),
                _pinButton('delete', isDelete: true),
              ],
            ),
          ),
          if (transfer.isProcessing)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _pinButton(String text, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () async {
        if (isDelete) {
          if (pin.isNotEmpty) {
            setState(() {
              pin = pin.substring(0, pin.length - 1);
            });
          }
          return;
        }
        if (pin.length >= 6) return;
        setState(() => pin += text);

        if (pin.length == 6) {
          final transfer = Provider.of<TransferProvider>(
            context,
            listen: false,
          );
          final success = await transfer.verifyPin(pin);
          if (success) {
            // PROSES API transferBalance
            final prefs = await SharedPreferences.getInstance();
            try {
              final currUserId = prefs.getString('user_id') ?? '';
              final api = ApiService();
              final messageTransfer = widget.note.isEmpty
                  ? 'Transfer ke ${transfer.selectedContact?.name}'
                  : widget.note;

              final message =
                  'Transfer ke ${transfer.selectedContact?.name} Berhasil!';

              // ✅ Gunakan widget.note di sini
              final result = await api.transferBalance(
                from: currUserId,
                to: transfer.selectedContact!.id,
                amount: transfer.amount?.toDouble() ?? 0,
                message: messageTransfer,
              );

              if (result['success'] && mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
                Provider.of<TransferProvider>(
                  context,
                  listen: false,
                ).resetAll();
                Navigator.popUntil(context, (route) => route.isFirst);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'Transfer gagal')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terjadi kesalahan')),
                );
              }
            }
          } else {
            setState(() => pin = '');
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('PIN Salah!')));
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: isDelete
              ? const Icon(Icons.backspace_outlined, size: 28)
              : Text(text, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}
