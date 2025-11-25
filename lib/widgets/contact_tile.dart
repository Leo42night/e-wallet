// widgets/contact_tile.dart
import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  // Daftar warna cantik untuk inisial (seperti WhatsApp)
  static final List<Color> _avatarColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 0.8),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.detail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasBankLogo = contact.bankLogoPath != 'assets/images/kontak_preview.jpg';

    if (hasBankLogo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          color: Colors.white,
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            contact.bankLogoPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(),
          ),
        ),
      );
    } else {
      return _buildInitialAvatar();
    }
  }

  Widget _buildInitialAvatar() {
    final String initial = contact.name.isNotEmpty
        ? contact.name.trim().split(' ').first[0].toUpperCase()
        : '?';

    // Warna random berdasarkan nama (sama setiap kali muncul)
    final int colorIndex = contact.name.hashCode.abs() % _avatarColors.length;
    final Color baseColor = _avatarColors[colorIndex];

    return CircleAvatar(
      radius: 26,
      backgroundColor: baseColor.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: baseColor,
        ),
      ),
    );
  }
}