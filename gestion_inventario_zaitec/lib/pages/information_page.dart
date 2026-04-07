import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/pages/citas/citas_page.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../styles.dart';
import 'menu_page.dart';


class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  final String direccionQuery = "Calle de Tarfia, 4, 41012 Sevilla"; 

  Future<void> _abrirGoogleMaps() async {
 
  final String urlString = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccionQuery)}";
  final Uri url = Uri.parse(urlString);

  try {
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("No se pudo abrir el mapa");
    }
  } catch (e) {
    debugPrint("Error detectado: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.white,
      appBar: AppBar(
        backgroundColor: AppStyles.white,
        elevation: 0,
        
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppStyles.black),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuPage()), //Aqui debe ir la pagina principal no esta 
                    );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Información", style: AppStyles.tituloPrincipal),
            const SizedBox(height: 20),

            // CONTENEDOR DE IMAGEN DE MAPA
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/mapa.jpg'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // BOTÓN COMO LLEGAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _abrirGoogleMaps,
                style: AppStyles.botonPrincipal.copyWith(
                  backgroundColor: WidgetStateProperty.all(const Color(0xFF666666)), // Gris como en tu diseño
                ),
                child: const Text("Como llegar"),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Horario:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // SECCIÓN HORARIOS
            AppStyles.buildHorarioRow("Lunes", "10:00-14:00-16:00-20:00"),
            AppStyles.buildHorarioRow("Martes", "09:00-14:00-16:00-19:00"),
            AppStyles.buildHorarioRow("Miércoles", "10:00-14:00-16:00-20:00"),
            AppStyles.buildHorarioRow("Jueves", "09:00-14:00-16:00-19:00"),
            AppStyles.buildHorarioRow("Viernes", "10:00-14:00-16:00-20:00"),
            AppStyles.buildHorarioRow("Sábado", "10:00-14:00"),
            AppStyles.buildHorarioRow("Domingo", "Cerrado", color: Colors.grey),

            const SizedBox(height: 30),
            const Text("Nuestro equipo:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // SECCIÓN EQUIPO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppStyles.buildTeamMember("Alejandro Gómez"),
                const SizedBox(width: 20),
                AppStyles.buildTeamMember("Pedro Portela"),
                const SizedBox(width: 20),
                AppStyles.buildTeamMember("Santiago Hoyos"),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


}