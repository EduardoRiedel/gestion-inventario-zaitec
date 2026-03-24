import 'package:flutter/material.dart';
import 'registration__page.dart';

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
      body: SafeArea( // <--- ESTO evita que el texto se esconda arriba del todo
        child: Center( // <--- ESTO obliga a centrarlo
          child: SingleChildScrollView( // <--- ESTO permite que se vea con el teclado abierto
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PRUEBA: Título con color rojo fuerte para que lo veas sí o sí
                const Text(
                  'ZAITEC PELUQUEROS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Cámbialo a rojo solo para probar
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gestión de Citas',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 50),
                
                // Campos de texto
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 30),
                
                // Botón de Login principal
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _login,
                  child: const Text('Login'),
                ),

                const SizedBox(height: 20),

                // NUEVO BOTÓN: Para usuarios sin cuenta
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ], // Cierre de children
            ),
          ),
        ),
      ),
    );
  }
}