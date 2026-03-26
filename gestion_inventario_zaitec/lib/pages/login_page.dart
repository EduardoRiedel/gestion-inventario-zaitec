import 'package:flutter/material.dart';
import 'registration__page.dart';
import '../styles.dart';
import 'citas_page.dart';
import 'package:gestion_inventario_zaitec/firebase/firebaseManager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _oscurecerPassword = true; // Por defecto la contraseña está oculta

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
      body: SafeArea(
        // <--- ESTO evita que el texto se esconda arriba del todo
        child: Center(
          // <--- ESTO obliga a centrarlo
          child: SingleChildScrollView(
            // <--- ESTO permite que se vea con el teclado abierto
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
                  decoration: AppStyles.fieldDecoration(
                    'Email',
                    Icons.email_outlined,
                  ), // Icono más fino
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Tu variable bool
                  decoration:
                      AppStyles.fieldDecoration(
                        'Password',
                        Icons.lock_outline,
                      ).copyWith(
                        // <--- Esto mantiene tus estilos y añade lo nuevo
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey, // O el color que prefieras
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: AppStyles.botonPrincipal,
                  onPressed: () {
                    final email = _emailController.text;
                    final password = _passwordController.text;

                    // Llamar al método de inicio de sesión del FirebaseManager
                    FirebaseManager().iniciarSesion(email, password);

                    // ESTO es lo que hace el salto de página:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgendaPage(),
                      ),
                    );
                  },
                  child: const Text('INICIAR SESIÓN'),
                ),

                const SizedBox(height: 20),

                // BOTÓN DE REGISTRO
                OutlinedButton(
                  style: AppStyles.botonSecundarioOutlined,
                  onPressed: () {
                    // ESTO es lo que hace el salto de página:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
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
