part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailAndPassword({required this.email, required this.password});
}

class SignUpWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  SignUpWithEmailAndPassword({required this.email, required this.password});
}

class SignOut extends AuthEvent {}

class LoggingOut extends AuthEvent {}

class CheckUserLoggedIn extends AuthEvent {}
