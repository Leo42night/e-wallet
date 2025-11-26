// screens/transfer_pick_contact_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/contact.dart';
import '../../providers/transfer_provider.dart';
import '../../widgets/contact_tile.dart';
import 'transfer_amount_screen.dart';

class TransferPickContactScreen extends StatefulWidget {
  const TransferPickContactScreen({super.key});

  @override
  State<TransferPickContactScreen> createState() => _TransferPickContactScreenState();
}

class _TransferPickContactScreenState extends State<TransferPickContactScreen> {
  final List<Contact> contacts = [
    Contact(id: '1', name: 'NURHASANAH', detail: '33170257', bankLogoPath: 'assets/images/aaabni.png'),
    Contact(id: '2', name: 'Khoirul Fuad', detail: '085895675549'),
    Contact(id: '3', name: 'Nicholas', detail: '085349363277'),
    Contact(id: '4', name: 'Satrio', detail: '089604009031'),
    Contact(id: '5', name: 'ZUKIFLI', detail: '2185528', bankLogoPath: 'assets/images/aaabni.png'),
    Contact(id: '6', name: 'SLAMET', detail: '75423246', bankLogoPath: 'assets/images/aaabni.png'),
    Contact(id: '7', name: 'SYAHRI', detail: '52438087', bankLogoPath: 'assets/images/aaabni.png'),
  ];

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