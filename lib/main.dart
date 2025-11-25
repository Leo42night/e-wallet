import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/saldo_providers.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SaldoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(fontFamily: 'Poppins'),
    );
  }
}
