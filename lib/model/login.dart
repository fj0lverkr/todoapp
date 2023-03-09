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
      if (credential.user!.emailVerified) {
        return LoginResult(true, credential.user?.uid);
      } else {
        await credential.user?.sendEmailVerification();
        return LoginResult(false, "Please verify your e-mail first!");
      }
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }

  Future<LoginResult> createUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return LoginResult(false,
          "An e-mail verification message has been sent to your address.");
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }
}
