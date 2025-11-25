import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onPulsa;
  final VoidCallback onPaketData;
  final VoidCallback onListrik;
  final VoidCallback onRiwayat;

  const QuickActions({
    super.key,
    required this.onPulsa,
    required this.onPaketData,
    required this.onListrik,
    required this.onRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _item(Icons.phone_android, "Pulsa", onPulsa),
          _item(Icons.language, "Paket Data", onPaketData),
          _item(Icons.electric_bolt, "Listrik", onListrik),
          _item(Icons.receipt_long, "Riwayat", onRiwayat),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
