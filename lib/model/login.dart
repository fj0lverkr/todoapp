import 'package:firebase_auth/firebase_auth.dart';

class LoginResult {
  final bool success;
  final String? message;

  LoginResult(this.success, this.message);
}

class TodoLogin {
  Future<void> _setDisplayName(
      String name, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(name);
    } on FirebaseException catch (e) {
      print(e.message.toString());
    }
  }

  Future<LoginResult> signInWithEmailAndPassword(String email, String password,
      [bool isFromCreate = false, String? displayName]) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user!.emailVerified) {
        return LoginResult(true, credential.user?.uid);
      } else {
        if (isFromCreate && displayName != null && displayName.isNotEmpty) {
          await _setDisplayName(displayName, email, password);
        }
        await credential.user!.sendEmailVerification();
        //FirebaseAuth.instance.signOut();
        return LoginResult(false,
            "An e-mail verification message has been sent to your address.");
      }
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }

  Future<LoginResult> createUser(
      String email, String password, String displayName) async {
    try {
      displayName = displayName == "" ? email : displayName;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      LoginResult result =
          await signInWithEmailAndPassword(email, password, true, displayName);
      FirebaseAuth.instance.signOut();
      return result;
    } on FirebaseAuthException catch (e) {
      return LoginResult(false, e.message.toString());
    }
  }
}
