String formatRupiah(double value) {
  final str = value.toStringAsFixed(0);
  return str.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}
