import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/pages/login_page.dart';
import '../styles.dart';
import 'package:gestion_inventario_zaitec/Firebase/FirebaseManager.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // <--- ESTO evita que el texto se esconda arriba del todo
        child: Center( // <--- ESTO obliga a centrarlo
          child: SingleChildScrollView( // <--- ESTO permite que se vea con el teclado abierto
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // PRUEBA: Título con color rojo fuerte para que lo veas sí o sí
                Text('ZAITEC PELUQUEROS', style: AppStyles.tituloPrincipal),
                const SizedBox(height: 10),

                Text('Gestión de Citas', style: AppStyles.subtitulo),

                const SizedBox(height: 50),
                
                // Campos de texto
                TextField(
                  controller: _emailController,
                  decoration: AppStyles.fieldDecoration('Email', Icons.email_outlined), // Icono más fino
                ),

                const SizedBox(height: 16),
                // Campo de contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  // Usamos Icons.lock_outline para el look minimalista
                  decoration: AppStyles.fieldDecoration('Password', Icons.lock_outline), 
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: AppStyles.botonPrincipal,
                  onPressed: () {

                    final email = _emailController.text;
                    final password = _passwordController.text;

                    // Llamar al método de registro del FirebaseManager
                    FirebaseManager().registrarUsuario(email, password);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Crear Cuenta'),
                  
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}