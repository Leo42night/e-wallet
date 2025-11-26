// screens/transfer_amount_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/transfer_provider.dart';
import 'transfer_confirm_pin_screen.dart';

class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key});

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  final TextEditingController _noteController = TextEditingController();

  static const int minAmount = 1000;
  static const int maxAmount = 999999999999;

  double? userBalance;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userBalance = prefs.getDouble('user_balance') ?? 0);
  }

  static final List<Color> _avatarColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userBalance == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<TransferProvider>(
      builder: (context, transfer, child) {
        final contact = transfer.selectedContact;
        final name = contact?.name ?? 'Penerima';
        final amount = transfer.amount ?? 0;

        final bool isTooLow = amount > 0 && amount < minAmount;
        final bool isInsufficient = amount > userBalance!;
        final bool isValid =
            amount >= minAmount &&
            amount <= maxAmount &&
            amount <= userBalance!;

        final formattedAmount =
            amount == 0 ? 'Rp0' : 'Rp${_formatRupiah(amount)}';

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF4E6),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Kirim Uang',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),

          // ===============================
          // FULLPAGE SCROLL (rapih & stabil)
          // ===============================
          body: Column(
            children: [
              // ==============================
              // Bagian ATAS — Header + Input
              // ==============================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(contact, name),

                      const SizedBox(height: 12),

                      _userBalanceDisplay(),

                      const SizedBox(height: 24),

                      _amountBox(formattedAmount),

                      const SizedBox(height: 8),
                      _amountErrors(isTooLow, isInsufficient),

                      const SizedBox(height: 20),

                      const Text('Catatan', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      _noteField(),
                    ],
                  ),
                ),
              ),

              // ==============================
              // NUMPAD
              // ==============================
              _numpad(transfer),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransferConfirmPinScreen(
                                  note: _noteController.text,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // WIDGET DETAIL (TERSTRUKTUR)
  // ==========================================

  Widget _header(contact, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(contact, name),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _userBalanceDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Saldo Anda: Rp${_formatRupiah(userBalance!.toInt())}",
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _amountBox(String formattedAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jumlah Kirim', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              formattedAmount,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountErrors(bool isTooLow, bool isInsufficient) {
    return SizedBox(
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTooLow)
            const Text(
              'Minimal transfer Rp1.000',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          if (isInsufficient)
            Text(
              'Saldo tidak mencukupi (tersedia Rp${_formatRupiah(userBalance!.toInt())})',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        hintText: 'Catatan (opsional)',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _numpad(TransferProvider transfer) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
            .map((d) => _numButton(d, transfer)),
        const SizedBox(),
        _numButton('0', transfer),
        _deleteButton(transfer),
      ],
    );
  }

  Widget _buildAvatar(contact, String name) {
    if (contact == null) {
      return const CircleAvatar(
          radius: 36,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 48));
    }

    final bool hasBankLogo =
        contact.photoUrl != 'assets/images/kontak_preview.jpg';

    if (hasBankLogo) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(72),
          child: Image.asset(
            contact.photoUrl,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(name),
          ),
        ),
      );
    }

    return _buildInitialAvatar(name);
  }

  Widget _buildInitialAvatar(String name) {
    final String initial =
        name.isNotEmpty ? name.trim().split(' ').first[0].toUpperCase() : '?';
    final int colorIndex = name.hashCode.abs() % _avatarColors.length;
    final Color baseColor = _avatarColors[colorIndex];

    return CircleAvatar(
      radius: 36,
      backgroundColor: baseColor.withAlpha(51), // 0.2
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: baseColor,
        ),
      ),
    );
  }

  Widget _numButton(String digit, TransferProvider transfer) {
    return GestureDetector(
      onTap: () {
        final current = transfer.amount ?? 0;
        final temp = current * 10 + int.parse(digit);
        if (temp > maxAmount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal transfer Rp999 miliar'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        transfer.setAmount(temp);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _deleteButton(TransferProvider transfer) {
    return GestureDetector(
      onTap: () => transfer.setAmount((transfer.amount ?? 0) ~/ 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, size: 28),
        ),
      ),
    );
  }

  String _formatRupiah(int number) {
    return number
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
