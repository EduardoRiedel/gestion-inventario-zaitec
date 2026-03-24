
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Cita.dart';

class FirebaseManager {
  FirebaseAuth get _auth => FirebaseAuth.instance; // instancia de firebase

  final CollectionReference citasIns = FirebaseFirestore.instance.collection('Citas'); // referencia a la colección de citas

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


}