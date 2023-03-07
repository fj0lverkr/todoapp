import 'package:firebase_auth/firebase_auth.dart';

class LoginResult {
  final bool success;
  final String? message;

  LoginResult(this.success, this.message);
}

class TodoLogin {
  Future<LoginResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return LoginResult(true, credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }

  Future<LoginResult> createUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return LoginResult(true, credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }
}
