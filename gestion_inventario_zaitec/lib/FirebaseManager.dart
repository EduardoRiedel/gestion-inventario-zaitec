
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';

class FirebaseManager {
  FirebaseAuth get _auth => FirebaseAuth.instance; // instancia de firebase

  var email= "Ejemplo@gmail.com"; // correo ejemplo
  var password= "Ejemplo123"; // contraseña Ejemplo

  // Método para Registro (El que tenías originalmente)
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



}