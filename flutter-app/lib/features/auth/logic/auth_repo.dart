import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:driveguard/common/exception.dart';
import 'package:driveguard/common/session_service.dart';
import 'package:driveguard/features/auth/data/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepo {
  final SupabaseClient supabaseClient;

  AuthRepo({required this.supabaseClient});
  Session? get currentUserSession => supabaseClient.auth.currentSession;
  Future<UserModel> signUpWithEmailPassword({
    required String uname,
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int age,
    required int exp,
    required File avatar,
  }) async {
    try {
      String? avatarUrl;

      final filePath = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Step 2: Get the public URL of the uploaded avatar
      final publicUrlResponse =
          supabaseClient.storage.from('avatars').getPublicUrl(filePath);

      avatarUrl = publicUrlResponse;

      // Step 3: Sign up the user with email, password, and metadata
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': uname,
          'phone_number': phoneNumber,
          'age': age,
          'exp': exp,
          'full_name': fullName,
          'avatar_url': avatarUrl,
        },
      );

      if (response.user == null) {
        throw ServerException('User is Null');
      }
      await SessionService.saveSession(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken!,
        userJson: response.user!.toJson().toString(),
      );
      return UserModel.fromJson(response.user!.toJson())
          .copyWith(email: currentUserSession!.user.email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      if (response.user == null) {
        throw ServerException('User is null');
      }
      await SessionService.saveSession(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken!,
        userJson: response.user!.toJson().toString(),
      );
      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future logOutUser() async {
    try {
      await supabaseClient.auth.signOut();
      await SessionService.clearSession();
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> restoreSession() async {
    final sessionData = await SessionService.getSession();
    if (sessionData != null) {
      final accessToken = sessionData['accessToken'];
      final refreshToken = sessionData['refreshToken'];
      final userJson = sessionData['userJson'];

      if (accessToken != null && refreshToken != null && userJson != null) {
        // Create a Session object
        final session = Session(
          accessToken: accessToken,
          refreshToken: refreshToken,
          tokenType: 'bearer', // Default token type
          user: User.fromJson(jsonDecode(userJson))!,
        );

        // Set the session
        await supabaseClient.auth.setSession(session as String);
      } else {
        // Clear session if tokens are null
        await SessionService.clearSession();
      }
    }
  }
}
