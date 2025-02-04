part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class LoggingIn extends AuthState {}

class LoggedIn extends AuthState {
  final User user;

  LoggedIn(this.user);
}

class LoggedOut extends AuthState {}

class SigningUp extends AuthState {}

class SignUpSuccess extends AuthState {
  final User user;

  SignUpSuccess(this.user);
}

class SignUpFailure extends AuthState {
  final String error;

  SignUpFailure(this.error);
}

class LoggingFailure extends AuthState {
  final String error;

  LoggingFailure(this.error);
}

class CheckingLoggedIn extends AuthState {}