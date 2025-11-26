// models/contact.dart
class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String telp;
  final double balance;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.telp,
    required this.balance
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      telp: json['telp'] ?? '',
      balance: (json['balance'] is int)
          ? (json['balance'] as int).toDouble()
          : (json['balance'] is double)
              ? json['balance']
              : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
    );
  }
}