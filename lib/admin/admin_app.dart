import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeScreen());
  }
}
