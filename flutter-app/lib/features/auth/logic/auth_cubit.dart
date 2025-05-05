import 'dart:io';

import 'package:driveguard/common/exception.dart';
import 'package:driveguard/features/auth/logic/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:driveguard/features/auth/data/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthStates extends Equatable {
  const AuthStates();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthAuthenticated extends AuthStates {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthStates {}

class AuthError extends AuthStates {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo _authRepo;

  AuthCubit({required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(AuthInitial());

  // Sign up with email and password
  Future<void> signUp({
    required String uname,
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int age,
    required int exp,
    required File avatar,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.signUpWithEmailPassword(
        uname: uname,
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        age: age,
        exp: exp,
        avatar: avatar,
      );
      emit(AuthAuthenticated(user));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.loginWithEmailPassword(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepo.logOutUser();
      emit(AuthUnauthenticated());
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Check if the user is already authenticated
  Future<void> checkAuthStatus() async {
    final session = _authRepo.currentUserSession;
    if (session != null) {
      final user = UserModel.fromJson(session.user.toJson());
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
