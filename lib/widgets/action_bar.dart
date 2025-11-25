import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onPindai;
  final VoidCallback onIsiSaldo;
  final VoidCallback onKirim;

  const ActionBar({
    super.key,
    required this.onPindai,
    required this.onIsiSaldo,
    required this.onKirim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _item(Icons.qr_code_scanner_outlined, "Pindai", onPindai),
          _divider(),
          _item(Icons.add_circle_outline, "Isi Saldo", onIsiSaldo),
          _divider(),
          _item(Icons.arrow_upward, "Kirim", onKirim),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white24);
}
