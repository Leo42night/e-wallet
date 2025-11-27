// // ========================================
// // screens/phone_login_screen.dart
// // ========================================
// class PhoneLoginScreen extends StatefulWidget {
//   const PhoneLoginScreen({super.key});

//   @override
//   State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
// }

// class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _phoneController = TextEditingController();
//   bool _isLoading = false;
//   String _verificationId = '';

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _verifyPhoneNumber() async {
//     final phoneNumber = _phoneController.text.trim();
    
//     if (phoneNumber.isEmpty) {
//       _showError('Masukkan nomor telepon');
//       return;
//     }

//     // Format nomor telepon (tambahkan +62 jika belum ada)
//     String formattedPhone = phoneNumber;
//     if (phoneNumber.startsWith('0')) {
//       formattedPhone = '+62${phoneNumber.substring(1)}';
//     } else if (!phoneNumber.startsWith('+')) {
//       formattedPhone = '+62$phoneNumber';
//     }

//     setState(() => _isLoading = true);

//     await _auth.verifyPhoneNumber(
//       phoneNumber: formattedPhone,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // Auto-verification (Android only)
//         await _signInWithCredential(credential);
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() => _isLoading = false);
//         _showError('Verifikasi gagal: ${e.message}');
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _isLoading = false;
//           _verificationId = verificationId;
//         });
        
//         // Navigate ke halaman OTP
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => OtpVerificationScreen(
//               verificationId: verificationId,
//               phoneNumber: formattedPhone,
//             ),
//           ),
//         );
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         _verificationId = verificationId;
//       },
//       timeout: const Duration(seconds: 60),
//     );
//   }

//   Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
//     try {
//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
      
//       final user = userCredential.user;
      
//       if (user != null && mounted) {
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
//       _showError('Login gagal: $e');
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
//         title: const Text('Masuk dengan Telepon'),
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
//               'Verifikasi Nomor Telepon',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Kami akan mengirimkan kode OTP ke nomor telepon Anda',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 32),
//             TextField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: 'Nomor Telepon',
//                 hintText: '08123456789',
//                 prefixText: '+62 ',
//                 prefixIcon: const Icon(Icons.phone),
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
//                 onPressed: _isLoading ? null : _verifyPhoneNumber,
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
//                         'Kirim Kode OTP',
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