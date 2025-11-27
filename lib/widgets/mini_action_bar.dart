import 'package:flutter/material.dart';

/// CLASS: QuickActions
/// FUNGSI: Widget untuk menampilkan 4 tombol aksi cepat di halaman home
/// KEGUNAAN: Memberikan shortcut ke fitur-fitur populer (Pulsa, Paket Data, Listrik, Riwayat)
/// TEMPAT DIGUNAKAN: Ditampilkan di HomeScreen antara header dan transaction history section
///
/// PARAMETER (Constructor) - Callback Functions:
///   - onPulsa: Function yang dipanggil saat user tap tombol "Pulsa"
///   - onPaketData: Function yang dipanggil saat user tap tombol "Paket Data"
///   - onListrik: Function yang dipanggil saat user tap tombol "Listrik"
///   - onRiwayat: Function yang dipanggil saat user tap tombol "Riwayat"
class QuickActions extends StatelessWidget {
  final VoidCallback onPulsa; // Callback untuk tombol Pulsa
  final VoidCallback onPaketData; // Callback untuk tombol Paket Data
  final VoidCallback onListrik; // Callback untuk tombol Listrik
  final VoidCallback onRiwayat; // Callback untuk tombol Riwayat

  const QuickActions({
    super.key,
    required this.onPulsa,
    required this.onPaketData,
    required this.onListrik,
    required this.onRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    // CONTAINER: Wadah utama untuk menyimpan 4 tombol aksi
    return Container(
      // MARGIN: Jarak dari tepi kiri-kanan layar (20 pixel di kiri dan kanan)
      margin: const EdgeInsets.symmetric(horizontal: 20),
      // PADDING: Jarak dalam dari tepi container ke konten (20 pixel atas-bawah)
      padding: const EdgeInsets.symmetric(vertical: 20),
      // DECORATION: Styling container dengan warna, border, dan shadow
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar container (putih)
        borderRadius: BorderRadius.circular(16), // Sudut melengkung (radius 16)
        border: Border.all(
          color: Colors.grey.shade200, // Border tipis berwarna abu-abu muda
        ),
        boxShadow: [
          // SHADOW: Bayangan di bawah container untuk efek elevasi
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ), // Warna shadow (hitam 5% opacity)
            blurRadius: 10, // Blur radius shadow
            offset: const Offset(0, 4), // Posisi shadow (bawah 4 pixel)
          ),
        ],
      ),
      // CHILD: Row yang menampilkan 4 tombol secara horizontal
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceEvenly, // Tombol tersebar merata dengan spacing sama
        children: [
          // Tombol 1: Pulsa
          _item(Icons.phone_android, "Pulsa", onPulsa),
          // Tombol 2: Paket Data
          _item(Icons.language, "Paket Data", onPaketData),
          // Tombol 3: Listrik
          _item(Icons.electric_bolt, "Listrik", onListrik),
          // Tombol 4: Riwayat
          _item(Icons.receipt_long, "Riwayat", onRiwayat),
        ],
      ),
    );
  }

  /// FUNGSI HELPER: _item()
  /// TUJUAN: Membuat satu item tombol aksi (icon + label)
  /// PARAMETER:
  ///   - icon: IconData untuk menampilkan ikon (misal: Icons.phone_android)
  ///   - label: String teks label di bawah ikon (misal: "Pulsa")
  ///   - onTap: VoidCallback yang dipanggil saat tombol di-tap
  /// RETURN: Widget yang berisi kolom ikon + teks yang bisa di-tap
  Widget _item(IconData icon, String label, VoidCallback onTap) {
    // GESTUREDETECTOR: Widget untuk mendeteksi tap/gestur dari user
    return GestureDetector(
      onTap: onTap, // Panggil callback saat user tap tombol
      child: Column(
        // COLUMN: Menyusun ikon dan label secara vertikal (ikon di atas, label di bawah)
        children: [
          // ICON: Menampilkan ikon dengan ukuran 28 dan warna abu-abu gelap
          Icon(
            icon,
            size: 28, // Ukuran ikon
            color: Colors.black87, // Warna ikon (hitam 87%)
          ),
          // SPACER: Jarak vertikal antara ikon dan label (8 pixel)
          const SizedBox(height: 8),
          // LABEL: Menampilkan teks label di bawah ikon
          Text(
            label, // Teks yang ditampilkan (misal: "Pulsa", "Paket Data")
            style: const TextStyle(
              fontSize: 12, // Ukuran font kecil
              color: Colors.black87, // Warna teks (hitam 87%)
            ),
          ),
        ],
      ),
    );
  }
}
