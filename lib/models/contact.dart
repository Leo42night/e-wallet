// models/contact.dart
class Contact {
  final String id;
  final String name;
  final String detail;
  final String bankLogoPath;

  const Contact({
    required this.id,
    required this.name,
    required this.detail,
    String? bankLogoPath,
  }) : bankLogoPath = bankLogoPath ?? 'assets/images/kontak_preview.jpg';
}