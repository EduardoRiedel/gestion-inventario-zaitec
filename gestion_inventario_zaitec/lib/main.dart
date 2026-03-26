import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/firebase/firebaseManager.dart';
import 'package:gestion_inventario_zaitec/firebase/firebase_options.dart';
import 'package:gestion_inventario_zaitec/pages/login_page.dart';
 // principal
Future<void> main() async {
  runApp(const MyApp());

  await Firebase.initializeApp( // inicializar firebase en el main
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quitamos la banda roja de DEBUG
      title: 'ZAITEC Gestión',
      theme: ThemeData(
        // CORRECCIÓN AQUÍ: Añadida la palabra ColorScheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Esta línea es la que lanza tu página de login
      home: const LoginPage(),
    );
  }
}
