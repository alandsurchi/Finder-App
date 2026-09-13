import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/config/app_config.dart';
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    try {
      // Web: the plugin takes the Web client id as [clientId] and rejects a
      // serverClientId. Android: the Android client (package + SHA-1) is
      // looked up automatically; the Web client id goes in [serverClientId]
      // so the ID token's audience matches what the backend verifies.
      // iOS has no OAuth client yet and falls back to Info.plist.
      final String? clientId = kIsWeb ? AppConfig.googleWebClientId : null;
      final String? serverClientId =
          kIsWeb ? null : AppConfig.googleWebClientId;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: clientId,
        serverClientId: serverClientId,
        scopes: ['email', 'profile', 'openid'],
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  static String _describe(Object e) {
    final text = e.toString();
    if (text.startsWith('Exception: ')) return text.substring(11);
    return 'Something went wrong. Please try again.';
  }

  @override
  Future<void> sendPasswordResetCode({required String email}) async {
    try {
      await _apiClient.post('/auth/forgot-password', {
        'email': email,
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
    }
  }

  @override
  Future<void> verifyResetCode({required String email, required String code}) async {
    try {
      await _apiClient.post('/auth/verify-reset-code', {
        'email': email,
        'code': code,
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
    }
  }

  @override
  Future<void> resendVerificationCode() async {
    try {
      await _apiClient.post('/auth/resend-verification', {});
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(_describe(e));
    }
  }
}


