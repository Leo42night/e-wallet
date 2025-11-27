// // ========================================
// // screens/otp_verification_screen.dart
// // ========================================
// class OtpVerificationScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber;

//   const OtpVerificationScreen({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//   });

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _otpController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   Future<void> _verifyOtp() async {
//     final otp = _otpController.text.trim();

//     if (otp.isEmpty || otp.length != 6) {
//       _showError('Masukkan kode OTP 6 digit');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otp,
//       );

//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);

//       final user = userCredential.user;

//       if (user != null) {
//         // Simpan ke database via API
//         final apiService = ApiService();
//         final result = await apiService.loginWithPhone(user);

//         if (result['success']) {
//           final prefs = await SharedPreferences.getInstance();

//           await prefs.setString('user_name', result['user']['name'] ?? 'User');
//           await prefs.setString('user_email', result['user']['email'] ?? '');
//           await prefs.setDouble(
//             'user_balance',
//             double.tryParse(result['user']['balance'] ?? '0') ?? 0.0,
//           );
//           await prefs.setString('user_id', result['user']['id'] ?? '');
//           await prefs.setString('user_photo_url', result['user']['photo_url'] ?? '');
//           await prefs.setString('user_telp', user.phoneNumber ?? '');

//           if (mounted) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (route) => false,
//             );
//           }
//         } else {
//           _showError("Gagal menyimpan data: ${result['error']}");
//         }
//       }
//     } catch (e) {
//       _showError('Kode OTP salah atau expired');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verifikasi OTP'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 32),
//             const Text(
//               'Masukkan Kode OTP',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Kode OTP telah dikirim ke ${widget.phoneNumber}',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 32),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: InputDecoration(
//                 labelText: 'Kode OTP',
//                 hintText: '123456',
//                 prefixIcon: const Icon(Icons.lock),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyOtp,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Verifikasi',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
