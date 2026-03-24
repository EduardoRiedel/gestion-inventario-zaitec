
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseManager {
  FirebaseAuth get _auth => FirebaseAuth.instance; // instancia de firebase

  var email= "Ejemplo@gmail.com"; // correo ejemplo
  var password= "Ejemplo123"; // contraseña Ejemplo

  // Método para Registro de Usuario
  Future<User?> registrarUsuario(String email, String password) async { 
    try {
      final credential = await _auth.createUserWithEmailAndPassword( // llamamal metodo de firebase para registrar
        email: email,
        password: password,
      );
      return credential.user; // devuelve las credenciales del usuario
    } on FirebaseAuthException catch (e) { // excepciones por si la contraseña es debil o ya existae el correo
      if (e.code == 'weak-password') {
        print('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con este correo.');
      }
        return null;
      }
    }

     // Método para Iniciar Sesión
    Future<User?> iniciarSesion(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword( // llama al metodo de firebase para iniciar sesión
        email: email,
        password: password,
      );
      return credential.user; // devuelve las credenciales del usuario si todo es correcto
    } on FirebaseAuthException catch (e) { // excepciones por si el correo no existe, la contraseña es incorrecta o el correo esta mal escrito.
    
      if (e.code == 'user-not-found') {
        print('No se encontró una cuenta con este correo.');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta.');
      } else if(e.code == 'invalid-email') {
        print('Correo electrónico no válido.');
      }
      print("se a iniciado sesion correctamente");
      return null;
    }
    catch (e) {     // captura cualquier otro error inesperado
      print('Error inesperado: $e');
      return null;
    }
    }

    // FILTRO DE CITAS

    FirebaseFirestore get _firestore => FirebaseFirestore.instance; // Instancia privada de firestore
    //Metodo apra obtener las citas para el peluquero
    Stream<QuerySnapshot> obtenerCitasPeluquero( {
      String? usuario, servicio,
      DateTime? fechaHora
    }) {
      // Apuntamos a la colección "Citas"
      Query query = _firestore.collection('Citas');
      // Filtro por Nombre de Usuario
      if (usuario != null && usuario.isNotEmpty) {
        query = query.where('Usuario', isEqualTo: usuario);
      }
      // Filtro por Servicio
      if (servicio != null && servicio.isNotEmpty) {
        query = query.where('Servicio', isEqualTo: servicio);
      }
      // Filtro por Fecha y Hora
      if (fechaHora != null) {
        DateTime inicio = DateTime(fechaHora.year, fechaHora.month, fechaHora.day); // Inicio del día
        DateTime fin = inicio.add(Duration(days: 1)); // Fin del día
        query = query.where('Fecha y Hora', isGreaterThanOrEqualTo: inicio, isLessThan: fin);
      }
    // Ordenamos por fecha y hora de forma ascendente (más próximas primero)
    return query.orderBy('Fecha y Hora',descending:false).snapshots(); // Retorna un stream de snapshots ordenados por fecha y hora
}
}