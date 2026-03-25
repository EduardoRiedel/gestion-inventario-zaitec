import 'package:flutter/material.dart';

class AppStyles {
  // --- 1. PALETA DE COLORES (Monocromática) ---
  static const Color black = Color(0xFF101010); // Negro suave, más elegante
  static const Color darkGrey = Color(0xFF303030); // Gris oscuro (para textos secundarios)
  static const Color grey = Color(0xFF757575); // Gris medio
  static const Color lightGrey = Color(0xFFE0E0E0); // Gris claro (para bordes suaves)
  static const Color offWhite = Color(0xFFF9F9F9); // Blanco hueso (para fondos alternativos)
  static const Color white = Colors.white;

  // --- 2. COLORES SEMÁNTICOS DE LA APP ---
  static const Color primaryColor = black; // Usamos negro como color de acento principal
  static const Color backgroundColor = white;
  static const Color errorColor = Colors.red;

  // --- 3. TEXTOS (Como tus H1, H2 en CSS) ---
  static const TextStyle tituloPrincipal = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800, // Extra bold para un look moderno
    color: primaryColor,
    letterSpacing: -0.5, // Letras un poco más juntas (muy moderno)
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

  // --- 4. INPUTS (Estilo de los cuadros de texto minimalista) ---
  static InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: grey), // Color de la etiqueta por defecto
      prefixIcon: Icon(icon, color: grey), // Icono en gris
      filled: true,
      fillColor: offWhite, // Fondo grisáceo muy claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Bordes redondeados más suaves
        borderSide: BorderSide.none, // Quitamos el borde por defecto
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: lightGrey), // Borde gris claro cuando no está seleccionado
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2), // Borde negro cuando estás escribiendo
      ),
    );
  }

  // --- 5. BOTONES PRINCIPALES (Negro) ---
  static final ButtonStyle botonPrincipal = ElevatedButton.styleFrom(
    backgroundColor: black, // Fondo negro
    foregroundColor: white, // Texto blanco
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 1, // Elevación mínima para un look plano/minimalista
  );

  // --- 6. BOTONES SECUNDARIOS / OUTLINED (Blanco con borde negro) ---
  // Úsalo para "¿No tienes cuenta? Regístrate aquí"
  static final ButtonStyle botonSecundarioOutlined = OutlinedButton.styleFrom(
    foregroundColor: black, // Texto negro
    side: const BorderSide(color: black, width: 1.5), // Borde negro
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}