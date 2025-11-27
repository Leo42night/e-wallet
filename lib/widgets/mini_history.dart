import 'package:flutter/material.dart';

/// CLASS: TransactionItem
/// FUNGSI: Widget untuk menampilkan satu item transaksi dalam list
/// KEGUNAAN: Ditampilkan di halaman history atau mini history sebagai kartu transaksi individual
///
/// PARAMETER (Constructor):
///   - icon: IconData untuk menampilkan ikon transaksi (misal: Icons.send, Icons.attach_money)
///   - title: String berisi deskripsi transaksi (misal: "Kirim ke Budi", "Terima dari Andi")
///   - date: String berisi tanggal/waktu transaksi (misal: "2 jam yang lalu", "01 Jan 2024")
///   - amount: String berisi nominal uang dengan format (misal: "Rp 50.000", "-Rp 100.000")
///   - color: Color untuk styling ikon dan nominal (merah=pengeluaran, hijau=pemasukan)
class TransactionItem extends StatelessWidget {
  final IconData icon; // Ikon yang ditampilkan di sebelah kiri
  final String title, date, amount; // Deskripsi, tanggal, dan nominal transaksi
  final Color color; // Warna untuk ikon dan teks nominal

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
    // LISTILE: Widget bawaan Flutter untuk menampilkan item list
    // Struktur: leading (kiri) | title/subtitle (tengah) | trailing (kanan)
    return ListTile(
      // LEADING: Avatar berbentuk lingkaran di sebelah kiri
      // FUNGSI: Menampilkan ikon transaksi dalam lingkaran
      leading: CircleAvatar(
        radius: 22, // Ukuran radius lingkaran avatar
        backgroundColor: Colors.grey[200], // Warna latar avatar (abu-abu muda)
        child: Icon(
          icon, // Ikon transaksi (send, money, arrow, dll)
          color: color, // Warna ikon sesuai parameter (merah/hijau)
          size: 24, // Ukuran ikon
        ),
      ),

      // TITLE: Teks utama di tengah (deskripsi transaksi)
      // FUNGSI: Menampilkan keterangan transaksi
      title: Text(
        title, // Misal: "Kirim ke Budi", "Top-up Saldo", "Terima dari Andi"
        style: const TextStyle(
          fontWeight: FontWeight.w500, // Font tebal medium (bukan bold penuh)
        ),
      ),

      // SUBTITLE: Teks sekunder di bawah title (tanggal/waktu transaksi)
      // FUNGSI: Menampilkan kapan transaksi terjadi
      subtitle: Text(
        date, // Misal: "2 jam yang lalu", "01 Jan 2024 14:30"
        style: const TextStyle(
          fontSize: 13, // Ukuran font lebih kecil dari title
        ),
      ),

      // TRAILING: Teks di sebelah kanan (nominal uang)
      // FUNGSI: Menampilkan jumlah uang yang ditransfer
      trailing: Text(
        amount, // Misal: "-Rp 50.000" (kirim) atau "+Rp 100.000" (terima)
        style: TextStyle(
          color: color, // Merah untuk pengeluaran, hijau untuk pemasukan
          fontWeight: FontWeight.bold, // Teks tebal agar menonjol
          fontSize: 16, // Ukuran font besar untuk emphasis
        ),
      ),
    );
  }
}
