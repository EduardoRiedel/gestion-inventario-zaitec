import 'package:flutter/material.dart';
import '../Modelos/servicio_cita.dart';

class MetodosCitas {
  // Añadimos 'context' y el 'servicio' como parámetros
  static void confirmarBorrado({
    required BuildContext context,
    required String citaId,
    required ServicioCita servicio,
    required VoidCallback onConfirmado,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar cita?"),
        content: const Text("Esta acción borrará la cita permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Llamamos al servicio para borrar
              await servicio.eliminarCita(citaId);
              
              // Ejecutamos la función de limpieza (ej: resetear el índice)
              onConfirmado();
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("BORRAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}