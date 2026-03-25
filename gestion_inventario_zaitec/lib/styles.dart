import 'package:flutter/material.dart';

class AppStyles {
  //PALETA DE COLORES
  static const Color black = Color(0xFF101010); // Negro suave
  static const Color darkGrey = Color(0xFF303030); // Gris oscuro 
  static const Color grey = Color(0xFF757575); // Gris medio
  static const Color lightGrey = Color(0xFFE0E0E0); // Gris claro 
  static const Color offWhite = Color(0xFFF9F9F9); // Blanco hueso
  static const Color white = Colors.white;

  //COLORES DE LA APP 
  static const Color primaryColor = black; 
  static const Color backgroundColor = white;
  static const Color errorColor = Colors.red;

  //TEXTOS
  static const TextStyle tituloPrincipal = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800, 
    color: primaryColor,
    letterSpacing: -0.5, 
  );

  static const TextStyle subtitulo = TextStyle(
    fontSize: 18,
    color: darkGrey,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: primaryColor,
    fontWeight: FontWeight.w400,
  );

  //INPUTS
  static InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: grey), 
      prefixIcon: Icon(icon, color: grey), 
      filled: true,
      fillColor: offWhite, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), 
        borderSide: BorderSide.none, 
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2), 
      ),
    );
  }

  //BOTONES PRINCIPALES
  static final ButtonStyle botonPrincipal = ElevatedButton.styleFrom(
    backgroundColor: black, 
    foregroundColor: white, 
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 1,
  );

  //BOTONES SECUNDARIOS 
  static final ButtonStyle botonSecundarioOutlined = OutlinedButton.styleFrom(
    foregroundColor: black, 
    side: const BorderSide(color: black, width: 1.5), 
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

    //Widget tabla horarios
   static Widget buildHorarioRow(String dia, String horas, {Color color = Colors.black54}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("· $dia:", style: TextStyle(color: color, fontSize: 15)),
          Text(horas, style: TextStyle(color: color, fontSize: 15)),
        ],
      ),
    );
  }

    //Windget miembros 
   static Widget buildTeamMember(String nombre) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

}