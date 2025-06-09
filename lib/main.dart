import 'package:agora_vc/src/presentation/screens/user_indentity_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One-to-One Video Call',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserIdentityScreen(),
    );
  }
}
