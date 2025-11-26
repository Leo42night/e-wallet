import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';

class ShowQrScreen extends StatelessWidget {
  const ShowQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Saya"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ID Anda",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              userId,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // QR CODE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: userId,
                version: QrVersions.auto,
                size: 260,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Tunjukkan QR ini untuk dipindai",
              style: TextStyle(color: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }
}