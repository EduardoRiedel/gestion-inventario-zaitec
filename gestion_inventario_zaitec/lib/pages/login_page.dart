import 'package:flutter/material.dart';
import 'registration__page.dart';
import '../styles.dart';
import 'citas_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Add login logic here
    final email = _emailController.text;
    final password = _passwordController.text;
    
    if (email.isNotEmpty && password.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( 
        child: Center( 
          child: SingleChildScrollView( 
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // título principal
                Text('ZAITEC PELUQUEROS', style: AppStyles.tituloPrincipal),
                const SizedBox(height: 10),

                Text('Gestión de Citas', style: AppStyles.subtitulo),

                const SizedBox(height: 50),
                
                // Campos de texto
                TextField(
                  controller: _emailController,
                  decoration: AppStyles.fieldDecoration('Email', Icons.email_outlined), 
                ),

                const SizedBox(height: 16),

                // Campo de contraseña 
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppStyles.fieldDecoration('Password', Icons.lock_outline), 
                ),

                const SizedBox(height: 30),
                
                // BOTÓN DE INICIO DE SESIÓN
                ElevatedButton(
                  style: AppStyles.botonPrincipal,
                  onPressed: () {
                   
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgendaPage()),
                    );
                  },
                  child: const Text('INICIAR SESIÓN'),
                ),
                
                

                const SizedBox(height: 20),

                // BOTÓN DE REGISTRO
                OutlinedButton(
                  style: AppStyles.botonSecundarioOutlined,
                  onPressed: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ], 
            ),
          ),
        ),
      ),
    );
  }
}