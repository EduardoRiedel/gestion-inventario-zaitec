import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/pages/login_page.dart';

void main() {
  runApp(const MyApp());
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