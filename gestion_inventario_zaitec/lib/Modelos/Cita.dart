class Cita {
  String? id; // El ID que genera Firebase
  final DateTime fechaHora;
  final int precio;
  final String servicio;
  final String usuario;

  Cita({ // constructor de la clase
    this.id, 
    required this.fechaHora, 
    required this.precio, 
    required this.servicio, 
    required this.usuario
  });

  // Para enviar a Firebase 
  Map<String, dynamic> toMap() {
    return {
      'Fecha y Hora': fechaHora,
      'Precio': precio,
      'Servicio': servicio,
      'Usuario': usuario,
    };
  }
}
