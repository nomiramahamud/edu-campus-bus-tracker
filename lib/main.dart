import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bus_app/firebase_options.dart';
import 'package:bus_app/theme/app_theme.dart';
import 'package:bus_app/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus App',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}