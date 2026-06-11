import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/domain/auth_user.dart';
import 'auth_service.dart';

class RailwayAuthService implements AuthService {
  final ApiClient _apiClient;

  const RailwayAuthService({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await _apiClient.setToken(token);

      return AuthUser(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        displayName: userData['displayName']?.toString(),
        photoUrl: userData['photoUrl']?.toString(),
        isVerified: userData['isVerified'] as bool? ?? true,
      );
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final res = await _apiClient.post('/auth/signup', {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      });

      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await _apiClient.setToken(token);

      return AuthUser(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        displayName: userData['displayName']?.toString(),
        photoUrl: userData['photoUrl']?.toString(),
        isVerified: userData['isVerified'] as bool? ?? true,
      );
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    try {
      final String? clientId = kIsWeb
          ? '685670849218-9vt84sr1ibi9dpqphtqqugcavkk4kn63.apps.googleusercontent.com'
          : (Platform.isIOS
              ? '685670849218-6vp6v6gpjujcb6krkqjcicd3gn5bcjeo.apps.googleusercontent.com'
              : null);

      final String? serverClientId = kIsWeb
          ? null
          : (Platform.isAndroid
              ? '685670849218-pah2cvt7m1ksjumqhbt5uvtb7815mb9u.apps.googleusercontent.com'
              : '685670849218-6vp6v6gpjujcb6krkqjcicd3gn5bcjeo.apps.googleusercontent.com');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: clientId,
        serverClientId: serverClientId,
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled by the user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Failed to retrieve Google ID token.');
      }

      final res = await _apiClient.post('/auth/google-login', {
        'idToken': idToken,
      });

      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await _apiClient.setToken(token);

      return AuthUser(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        displayName: userData['displayName']?.toString(),
        photoUrl: userData['photoUrl']?.toString(),
        isVerified: userData['isVerified'] as bool? ?? true,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  @override
  Future<void> sendPasswordResetCode({required String email}) async {
    try {
      await _apiClient.post('/auth/forgot-password', {
        'email': email,
      });
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> verifyResetCode({required String email, required String code}) async {
    try {
      await _apiClient.post('/auth/verify-reset-code', {
        'email': email,
        'code': code,
      });
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post('/auth/reset-password', {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> verifyEmail({required String code}) async {
    try {
      final res = await _apiClient.post('/auth/verify-email', {
        'code': code,
      });
      final token = res['token'] as String;
      final userData = res['user'] as Map<String, dynamic>;

      await _apiClient.setToken(token);

      return AuthUser(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        displayName: userData['displayName']?.toString(),
        photoUrl: userData['photoUrl']?.toString(),
        isVerified: userData['isVerified'] as bool? ?? true,
      );
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> resendVerificationCode() async {
    try {
      await _apiClient.post('/auth/resend-verification', {});
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }
}


