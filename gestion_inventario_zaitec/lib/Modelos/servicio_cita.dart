import 'package:cloud_firestore/cloud_firestore.dart';
import '../Modelos/Cita.dart'; 

class ServicioCita {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenemos las citas de un día específico
  Stream<List<Cita>> getCitasPorDia(DateTime dia) {
    // Definimos el inicio y fin del día para filtrar
    DateTime inicioDia = DateTime(dia.year, dia.month, dia.day, 0, 0);
    DateTime finDia = DateTime(dia.year, dia.month, dia.day, 23, 59);

    return _db.collection('Citas')
        .where('fechaHora', isGreaterThanOrEqualTo: inicioDia)
        .where('fechaHora', isLessThanOrEqualTo: finDia)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cita.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Guardamos una nueva cita
  Future<void> crearCita(Cita cita) {
    return _db.collection('Citas').add(cita.toMap());
  }
  // Borrar Cita creada
Future<void> eliminarCita(String id) {
  return _db.collection('Citas').doc(id).delete();
}
}