import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/interest_provider.dart';
import 'screens/user_home_screen.dart';

class UserAppRoot extends StatelessWidget {
  const UserAppRoot({super.key});

  static Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: firebaseOptionskey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => InterestsProvider())],
      child: MaterialApp(
        title: 'Event Finder App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: const Color(0xFFF7F7FA),
        ),
        home: const UserHomeScreen(),
      ),
    );
  }
}
