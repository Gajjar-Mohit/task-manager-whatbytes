import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmanager/core/exceptions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Either<AuthException, User?>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return left(AuthException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<AuthException, User?>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return left(AuthException(e.message ?? 'Something went wrong'));
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      return user;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
