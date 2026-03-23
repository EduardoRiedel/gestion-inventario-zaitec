
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';

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
}