import 'package:flutter/material.dart';

import 'package:gestion_inventario_zaitec/pages/citas/citas_page.dart';
import 'package:gestion_inventario_zaitec/pages/information_page.dart';
import 'Servicio_page.dart';
 
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87, size: 28),
            onPressed: () {
              // Acción del menú hamburguesa
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
 
                // Título con borde rojo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
                  ),
                  child: const Text(
                    'ZAITEC PELUQUEROS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
 
                const Spacer(flex: 2),
 
                // Botón CITAS
                _MenuButton(
                  label: 'CITAS',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgendaPage()),
                    );
                  },
                ),
 
                const SizedBox(height: 16),
              // Botón SERTVICIOS
                _MenuButton(
                  label: 'SERVICIOS',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServicesPage()),
                    );
                  },
                ),
               
 
                const SizedBox(height: 16),
 
                // Botón INFORMACIÓN
                _MenuButton(
                  label: 'INFORMACIÓN',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InformacionPage()),
                    );
                  },
                ),
 
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
 
  const _MenuButton({
    required this.label,
    required this.onPressed,
  });
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAAAAAA),
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}