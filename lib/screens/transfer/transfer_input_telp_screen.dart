// screens/transfer_input_number_screen.dart
import 'package:e_wallet/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/transfer_provider.dart';
import 'transfer_amount_screen.dart';

class TransferInputNumberScreen extends StatefulWidget {
  const TransferInputNumberScreen({super.key});

  @override
  State<TransferInputNumberScreen> createState() => _TransferInputNumberScreenState();
}

class _TransferInputNumberScreenState extends State<TransferInputNumberScreen>
    with AutomaticKeepAliveClientMixin {
  // Biar state tidak reset saat kembali dari TransferAmountScreen
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  // Cek apakah nomor ada di database
  Future<User?> _findContactByTelp(String telp) async {
    final api = ApiService();
    final result = await api.getUserDataByEmail(telp);
    if(result['success'] == true) return User.fromJson(result['user'] ?? {});
    return null;
  }

  Future<void> _validateAndProceed(String input) async {
    final trimmed = input.trim();

    // Reset state
    if (!mounted) return;
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    // Validasi dasar
    if (trimmed.isEmpty) {
      setState(() {
        _errorText = 'Masukkan nomor handphone atau rekening';
        _isLoading = false;
      });
      return;
    }

    if (trimmed.length < 8) {
      setState(() {
        _errorText = 'Nomor terlalu pendek';
        _isLoading = false;
      });
      return;
    }

    // Cek di database
    final contact = await _findContactByTelp(trimmed);

    if (!mounted) return;

    if (contact == null) {
      setState(() {
        _errorText = 'Nomor tidak terdaftar';
        _isLoading = false;
      });
      return;
    }

    // SUCCESS! Nomor ditemukan
    Provider.of<TransferProvider>(context, listen: false)
      ..setManualNumber(trimmed)
      ..selectContact(contact); // langsung set contact!

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransferAmountScreen()),
    ).then((_) {
      // Saat kembali dari TransferAmountScreen → reset input & error
      if (mounted) {
        _controller.clear();
        setState(() {
          _errorText = null;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // untuk AutomaticKeepAliveClientMixin

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomor Handphone / Nomor Rekening Bank',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Cari atau masukkan nomor',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              errorText: _errorText,
              errorMaxLines: 2,
              errorStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            onSubmitted: _isLoading ? null : (value) => _validateAndProceed(value),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _validateAndProceed(_controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Lanjutkan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}