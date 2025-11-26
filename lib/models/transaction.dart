// MODEL TRANSAKSI
class TransactionModel {
  final String id;
  final String fromId;
  final String toId;
  final double amount;
  final String message;
  final DateTime createdAt;
  final String photoUrl; // another user
  final String email; // another user

  // constructor
  TransactionModel({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.message,
    required this.createdAt,
    required this.photoUrl,
    required this.email,
  });

  // dipakai untuk data dari API
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      fromId: json['from_id'].toString(),
      toId: json['to_id'].toString(),
      amount: double.parse(json['amount'].toString()),
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      photoUrl: json['photo_url'] ?? '',
      email: json['email'] ?? '',
    );
  }
}