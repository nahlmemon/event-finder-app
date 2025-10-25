import 'package:event_finder/user/screens/user_home_screen.dart';
import 'package:flutter/material.dart';

class UserEventApp extends StatelessWidget {
  const UserEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      ),
      home: const UserHomeScreen(),
    );
  }
}
