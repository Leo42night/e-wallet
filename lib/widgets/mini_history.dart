import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title, date, amount;
  final Color color;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(date, style: const TextStyle(fontSize: 13)),
      trailing: Text(
        amount,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
