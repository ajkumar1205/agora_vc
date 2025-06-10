import 'package:agora_vc/di.dart';
import 'package:agora_vc/firebase_options.dart';
import 'package:agora_vc/src/core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DependencyManager.injectDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'One-to-One Video Call',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router.config(),
    );
  }
}
