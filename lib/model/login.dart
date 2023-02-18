import 'package:todoapp/model/secret.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoLogin {
  Future<UserCredential> signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: firebaseEmail, password: firebasePassword);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.toString());
    }
  }
}
