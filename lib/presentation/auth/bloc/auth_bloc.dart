import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanager/services/auth/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    AuthService authService = AuthService();
    on<AuthEvent>((event, emit) {});
    on<SignUpWithEmailAndPassword>(
      (event, emit) async {
        emit(SigningUp());
        var user = await authService.signUpWithEmailAndPassword(
            event.email, event.password);
        user.fold(
          (l) => emit(SignUpFailure(l.message)),
          (r) {
            if (r != null) {
              emit(SignUpSuccess(r));
            } else {
              emit(SignUpFailure('Something went wrong'));
            }
          },
        );
      },
    );
    on<SignInWithEmailAndPassword>(
      (event, emit) async {
        emit(LoggingIn());
        var user = await authService.signInWithEmailAndPassword(
            event.email, event.password);
        user.fold(
          (l) => emit(LoggingFailure(l.message)),
          (r) {
            if (r != null) {
              emit(LoggedIn(r));
            } else {
              emit(LoggingFailure('Something went wrong'));
            }
          },
        );
      },
    );
    on<SignOut>((event, emit) async {
      await authService.signOut();
      emit(LoggedOut());
    });
    on<CheckUserLoggedIn>((event, emit) async {
      final user = await authService.getCurrentUser();
      if (user != null) {
        emit(LoggedIn(user));
      } else {
        emit(LoggedOut());
      }
    });
  }
}
