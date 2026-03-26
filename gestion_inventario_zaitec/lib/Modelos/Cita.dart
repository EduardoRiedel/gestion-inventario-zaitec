class Cita {
  String? id;
  final DateTime fechaHora;
  final int precio;
  final String servicio;
  final String usuario;

  Cita({this.id, required this.fechaHora, required this.precio, required this.servicio, required this.usuario});

  // Enviar a Firebase (toMap)
  Map<String, dynamic> toMap() {
    return {
      'fechaHora': fechaHora, 
      'precio': precio,
      'servicio': servicio,
      'usuario': usuario,
    };
  }

  // Recibir datos de Firebase (fromMap)
  factory Cita.fromMap(Map<String, dynamic> map, String documentId) {
    return Cita(
      id: documentId,
      fechaHora: (map['fechaHora'] as dynamic).toDate().toLocal(), // Convertir Timestamp a DateTime
      precio: map['precio'] ?? 0,
      servicio: map['servicio'] ?? '',
      usuario: map['usuario'] ?? '',
    );
  }
}