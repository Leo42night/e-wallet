import 'package:flutter/material.dart';
import 'transfer_pick_contact_screen.dart';
import 'transfer_input_number_screen.dart';

class TransferMainScreen extends StatefulWidget {
  const TransferMainScreen({super.key});

  @override
  State<TransferMainScreen> createState() => _TransferMainScreenState();
}

class _TransferMainScreenState extends State<TransferMainScreen> {
  int _selectedIndex = 0; // 0 = Pilih Kontak, 1 = Masukkan Nomor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF4E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kirim Uang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header dengan warna krem
          Container(
            color: const Color(0xFFFFF4E6),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    text: 'Pilih Kontak',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton(
                    text: 'Masukkan Nomor',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _selectedIndex == 0
                ? const TransferPickContactScreen()
                : const TransferInputNumberScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC876) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.black : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }
}