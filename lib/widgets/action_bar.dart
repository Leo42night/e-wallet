import 'package:flutter/material.dart';

/// CLASS: ActionBar
/// FUNGSI: Widget untuk menampilkan 3 tombol aksi utama di header home screen
/// KEGUNAAN: Memberikan akses cepat ke fitur scanning QR, top-up saldo, dan transfer uang
/// TEMPAT DIGUNAKAN: Ditampilkan di HomeScreen bagian header (bawah info saldo)
/// STYLING: Latar belakang hitam dengan teks putih
///
/// PARAMETER (Constructor) - Callback Functions:
///   - onPindai: Function yang dipanggil saat user tap tombol "Pindai"
///   - onIsiSaldo: Function yang dipanggil saat user tap tombol "Isi Saldo"
///   - onKirim: Function yang dipanggil saat user tap tombol "Kirim"
class ActionBar extends StatelessWidget {
  final VoidCallback onPindai; // Callback untuk tombol Pindai QR
  final VoidCallback onIsiSaldo; // Callback untuk tombol Isi Saldo
  final VoidCallback onKirim; // Callback untuk tombol Kirim Uang

  const ActionBar({
    super.key,
    required this.onPindai,
    required this.onIsiSaldo,
    required this.onKirim,
  });

  @override
  Widget build(BuildContext context) {
    // CONTAINER: Wadah utama untuk 3 tombol aksi
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ), // Jarak dalam atas-bawah (20 pixel)
      decoration: BoxDecoration(
        color: Colors.black, // Warna latar hitam
        borderRadius: BorderRadius.circular(16), // Sudut melengkung (radius 16)
      ),
      // ROW: Menyusun 3 tombol secara horizontal dengan pembatas di tengah
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Spasi sama rata
        children: [
          // TOMBOL 1: Pindai QR
          _item(Icons.qr_code_scanner_outlined, "Pindai", onPindai),
          // PEMBATAS 1: Garis vertikal putih semi-transparan
          _divider(),
          // TOMBOL 2: Isi Saldo
          _item(Icons.add_circle_outline, "Isi Saldo", onIsiSaldo),
          // PEMBATAS 2: Garis vertikal putih semi-transparan
          _divider(),
          // TOMBOL 3: Kirim Uang
          _item(Icons.arrow_upward, "Kirim", onKirim),
        ],
      ),
    );
  }

  /// FUNGSI HELPER: _item()
  /// TUJUAN: Membuat satu tombol aksi dengan ikon dan label
  /// PARAMETER:
  ///   - icon: IconData untuk ikon tombol (misal: Icons.qr_code_scanner_outlined)
  ///   - label: String teks label tombol (misal: "Pindai", "Kirim")
  ///   - onTap: VoidCallback yang dipanggil saat tombol di-tap
  /// RETURN: Widget Expanded yang berisi kolom ikon + teks yang bisa di-tap
  Widget _item(IconData icon, String label, VoidCallback onTap) {
    // EXPANDED: Membuat tombol mengambil space yang sama (1/3 dari width)
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // Panggil callback saat user tap tombol
        child: Column(
          // COLUMN: Menyusun ikon dan label secara vertikal
          children: [
            // ICON: Menampilkan ikon putih dengan ukuran 28
            Icon(
              icon,
              color: Colors.white, // Warna ikon putih
              size: 28, // Ukuran ikon
            ),
            // SPACER: Jarak vertikal antara ikon dan label (6 pixel)
            const SizedBox(height: 6),
            // LABEL: Menampilkan teks label di bawah ikon
            Text(
              label, // Teks yang ditampilkan (misal: "Pindai", "Kirim")
              style: const TextStyle(
                color: Colors.white, // Teks berwarna putih
                fontSize: 13, // Ukuran font kecil
                fontWeight: FontWeight.w500, // Font semi-bold (medium weight)
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FUNGSI HELPER: _divider()
  /// TUJUAN: Membuat garis pemisah vertikal antara tombol
  /// RETURN: Container berupa garis tipis putih semi-transparan
  /// FUNGSI: Memisahkan visual antara 3 tombol untuk clarity
  Widget _divider() => Container(
    width: 1, // Lebar garis (1 pixel)
    height: 40, // Tinggi garis (40 pixel)
    color: Colors.white24, // Warna putih 24% opacity (semi-transparan)
  );
}
