// screens/transfer_pick_contact_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/transfer_provider.dart';
import '../../widgets/contact_tile.dart';
import 'transfer_amount_screen.dart';

class TransferPickContactScreen extends StatefulWidget {
  const TransferPickContactScreen({super.key});

  @override
  State<TransferPickContactScreen> createState() => _TransferPickContactScreenState();
}

class _TransferPickContactScreenState extends State<TransferPickContactScreen> {
  final List<User> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ContactTile(
            contact: contact,
            onTap: () {
              Provider.of<TransferProvider>(context, listen: false).selectContact(contact);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferAmountScreen()),
              );
            },
          );
        },
      ),
    );
  }
}