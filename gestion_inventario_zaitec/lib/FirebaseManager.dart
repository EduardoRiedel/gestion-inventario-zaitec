
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';

class FirebaseManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var email= "Ejemplo@gmail.com";
  var password= "Ejemplo123";

  // Método para Registro (El que tenías originalmente)
  Future<User?> registrarUsuario(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con este correo.');
      }
      return null;
    }
  }



}