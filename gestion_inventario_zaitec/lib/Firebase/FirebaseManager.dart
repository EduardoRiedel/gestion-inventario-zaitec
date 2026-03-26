
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/pages/login_page.dart';
import '../Modelos/Cita.dart';

class FirebaseManager {
  FirebaseAuth get _auth => FirebaseAuth.instance; // instancia de firebase

  final CollectionReference citasIns = FirebaseFirestore.instance.collection('Citas'); // referencia a la colección de citas
 
  // Método para Registro de Usuario
 Future<void> registrarUsuario(BuildContext context, String email, String password, String confirmPassword) async {
  
  //Validación de contraseñas
  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Las contraseñas no coinciden"), backgroundColor: Colors.red),
    );
    return; 
  }

  try {
    // Registro en Firebase
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Muestro el "Toast" y navego
    if (context.mounted) {
      //aviso de éxito 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Cuenta creada con éxito! Redirigiendo..."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Duración
        ),
      );

      //Espera para que el usuario lea el mensage
      await Future.delayed(const Duration(seconds: 1));

      // LoginPage
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }

  } on FirebaseAuthException catch (e) {
    // Error SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Contraseña demasiado débil"), backgroundColor: Colors.orange),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error inesperado"), backgroundColor: Colors.red),
      );
    }
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

    // Método para crear cita
  Future<void> crearNuevaCita({ // parametros necesarios para la cita
    required String servicio,
    required String precio,
    required String usuario,
    required DateTime fechaElegida, 
  }) async {
    try {
      Cita nuevaCita = Cita( // constructor 
        servicio: servicio,
        precio: int.tryParse(precio) ?? 0,
        usuario: usuario,
        fechaHora: fechaElegida, 
      );

      await citasIns.add(nuevaCita.toMap()); // añade la cita a firebase
      print("Cita creada");
    } catch (e) {
      print("Error al crear: $e");
    }
  }

 // Metodo para actualizar cita
  Future<void> editarCita({  // parametros necesarios para la actualización
    required String id,
    required String servicio,
    required String precio,
    required String usuario,
    required DateTime fecha,
  }) async {
    try {
      Cita editada = Cita( // constructor
        servicio: servicio,
        precio: int.tryParse(precio) ?? 0, // la interrogacion es para manejar el caso donde la conversion falle
        usuario: usuario,
        fechaHora: fecha,
      );
      await citasIns.doc(id).update(editada.toMap());
    } catch (e) {
      print("Error al editar: $e");
    }
  }

// Metodo para eliminar Citas
Future<void> eliminarCita({required String id}) async { // parametros para eliminar cita
    try {
      await citasIns.doc(id).delete();
    } catch (e) {
      print("Error al eliminar: $e");
    }
  }


    // GESTION DE CITAS

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