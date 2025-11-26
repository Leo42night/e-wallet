import 'package:e_wallet/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'package:e_wallet/providers/transfer_provider.dart';
import 'package:e_wallet/models/user.dart';
import 'package:e_wallet/screens/transfer/transfer_amount_screen.dart';
import 'package:e_wallet/screens/qr/show_qr_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 1000,
  );

  String? scannedValue;
  bool isProcessing = false;
  DateTime? lastScanTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // ✅ FUNGSI BARU: Pick image dari galeri dan scan QR
  Future<void> _pickImageAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() => isProcessing = true);

      // ✅ Gunakan Google ML Kit untuk scan QR dari gambar
      final inputImage = mlkit.InputImage.fromFilePath(image.path);
      final barcodeScanner = mlkit.BarcodeScanner();
      
      try {
        final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
        
        if (barcodes.isEmpty) {
          if (!mounted) return;
          setState(() => isProcessing = false);
          _showErrorDialog("QR Code tidak ditemukan dalam gambar");
          return;
        }

        final code = barcodes.first.rawValue;
        if (code == null || code.isEmpty) {
          if (!mounted) return;
          setState(() => isProcessing = false);
          _showErrorDialog("QR Code tidak valid");
          return;
        }

        // Vibrate ketika berhasil scan
        bool? canVibrate = await Vibration.hasVibrator();
        if(canVibrate == true) Vibration.vibrate();

        // Process QR code
        await _processQRCode(code);
        
      } finally {
        barcodeScanner.close();
      }
      
    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      _showErrorDialog("Gagal membaca gambar: ${e.toString()}");
    }
  }

  void handleScan(BarcodeCapture capture) async {
    if (isProcessing) return;
    
    final now = DateTime.now();
    if (lastScanTime != null && now.difference(lastScanTime!).inMilliseconds < 1500) {
      return;
    }

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      scannedValue = code;
      isProcessing = true;
      lastScanTime = now;
    });

    await cameraController.stop();

    bool? canVibrate = await Vibration.hasVibrator();
    if(canVibrate == true) Vibration.vibrate();

    await _processQRCode(code);
  }

  // ✅ REFACTOR: Ekstrak logika proses QR ke fungsi terpisah
  Future<void> _processQRCode(String code) async {
    final scannedContact = await _fetchUserFromQR(code);

    if (!mounted) return;

    if (scannedContact != null) {
      Provider.of<TransferProvider>(context, listen: false).selectContact(scannedContact);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              const Text("Scan Berhasil", style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("QR Code berhasil terdeteksi:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          scannedContact.photoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scannedContact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Text(
                            scannedContact.email,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "ID: $code",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isProcessing = false);
                cameraController.start();
              },
              child: const Text("Scan Lagi", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransferAmountScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Lanjutkan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              const Text("QR Tidak Valid", style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("QR Code tidak ditemukan dalam sistem."),
              const SizedBox(height: 8),
              Text(
                "ID: $code",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isProcessing = false);
                cameraController.start();
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }
  }

  // ✅ FUNGSI BARU: Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text("Error", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<User?> _fetchUserFromQR(String email) async {
    try {
      final api = ApiService();
      final result = await api.getUserDataByEmail(email);
      if (result['success'] == true) {
        return User.fromJson(result['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan QR", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ✅ TOMBOL BARU: Pick dari galeri
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: isProcessing ? null : _pickImageAndScan,
          ),
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: handleScan,
            controller: cameraController,
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ...List.generate(4, (index) {
                          final positions = [
                            (top: 0.0, left: 0.0, right: null, bottom: null),
                            (top: 0.0, left: null, right: 0.0, bottom: null),
                            (top: null, left: 0.0, right: null, bottom: 0.0),
                            (top: null, left: null, right: 0.0, bottom: 0.0),
                          ];
                          return Positioned(
                            top: positions[index].top,
                            left: positions[index].left,
                            right: positions[index].right,
                            bottom: positions[index].bottom,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: index < 2 ? const BorderSide(color: Colors.orange, width: 4) : BorderSide.none,
                                  left: index % 2 == 0 ? const BorderSide(color: Colors.orange, width: 4) : BorderSide.none,
                                  right: index % 2 == 1 ? const BorderSide(color: Colors.orange, width: 4) : BorderSide.none,
                                  bottom: index >= 2 ? const BorderSide(color: Colors.orange, width: 4) : BorderSide.none,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          "Arahkan QR code ke dalam frame",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isProcessing)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ClipPath(
            clipper: ScanAreaClipper(),
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          // Toggle Button untuk pergi ke Show QR Screen
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ShowQrScreen()),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.qr_code, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanAreaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanAreaSize = 260.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final scanAreaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      const Radius.circular(16),
    );

    path.addRRect(scanAreaRect);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}