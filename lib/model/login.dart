import 'package:firebase_auth/firebase_auth.dart';

class TodoLogin {
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.toString());
    }
  }
}
