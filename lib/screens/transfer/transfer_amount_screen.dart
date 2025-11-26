// screens/transfer_amount_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transfer_provider.dart';
import 'transfer_confirm_pin_screen.dart';

class TransferAmountScreen extends StatefulWidget {
  const TransferAmountScreen({super.key});

  @override
  State<TransferAmountScreen> createState() => _TransferAmountScreenState();
}

class _TransferAmountScreenState extends State<TransferAmountScreen> {
  final TextEditingController _noteController = TextEditingController();

  static const int minAmount = 50000;
  static const int maxAmount = 999999999999;

  int get userBalance => 500000000; // nanti dari API

  // Warna cantik untuk inisial (sama seperti ContactTile)
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
    return Consumer<TransferProvider>(
      builder: (context, transfer, child) {
        final contact = transfer.selectedContact;
        final number = transfer.enteredNumber;
        final name = contact?.name ?? 'Penerima';
        final amount = transfer.amount ?? 0;

        final bool isTooLow = amount > 0 && amount < minAmount;
        final bool isInsufficient = amount > userBalance;
        final bool isValid = amount >= minAmount && amount <= maxAmount && amount <= userBalance;

        final String formattedAmount = amount == 0 ? 'Rp0' : 'Rp${_formatRupiah(amount)}';

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF4E6),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Kirim Uang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              children: [
                // HEADER PENERIMA
                Container(
                  color: const Color(0xFFFFF4E6),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // AVATAR — SAMA PERSIS SEPERTI CONTACT TILE
                          _buildAvatar(contact, name),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(number, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // JUMLAH KIRIM
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah Kirim', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                amount == 0 ? 'Rp0' : formattedAmount,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          // RUANG ERROR — tetap tinggi
                          SizedBox(
                            height: 44,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isTooLow)
                                    const Text('Minimal transfer Rp50.000', style: TextStyle(color: Colors.red, fontSize: 13)),
                                  if (isInsufficient)
                                    Text('Saldo tidak mencukupi (tersedia Rp${_formatRupiah(userBalance)})',
                                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          const Text('Catatan', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Ini saya kasih uang',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // NOMINAL BESAR
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        amount == 0 ? 'Rp0' : formattedAmount,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // NUMPAD
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    ...['1','2','3','4','5','6','7','8','9'].map((d) => _numButton(d, transfer)),
                    const SizedBox(),
                    _numButton('0', transfer),
                    _deleteButton(transfer),
                  ],
                ),

                const SizedBox(height: 20),

                // TOMBOL SELESAI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransferConfirmPinScreen(note: _noteController.text)))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Selesai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // AVATAR — SAMA PERSIS DENGAN ContactTile
  Widget _buildAvatar(contact, String name) {
    if (contact == null) {
      return const CircleAvatar(radius: 36, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 48));
    }

    final bool hasBankLogo = contact.bankLogoPath != 'assets/images/kontak_preview.jpg';

    if (hasBankLogo) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(72),
          child: Image.asset(
            contact.bankLogoPath,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(name),
          ),
        ),
      );
    } else {
      return _buildInitialAvatar(name);
    }
  }

  Widget _buildInitialAvatar(String name) {
    final String initial = name.isNotEmpty ? name.trim().split(' ').first[0].toUpperCase() : '?';
    final int colorIndex = name.hashCode.abs() % _avatarColors.length;
    final Color baseColor = _avatarColors[colorIndex];

    return CircleAvatar(
      radius: 36,
      backgroundColor: baseColor.withOpacity(0.2),
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
            const SnackBar(content: Text('Maksimal transfer Rp999 miliar'), backgroundColor: Colors.red),
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
        child: Center(child: Text(digit, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500))),
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
        child: const Center(child: Icon(Icons.backspace_outlined, size: 28)),
      ),
    );
  }

  String _formatRupiah(int number) {
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}