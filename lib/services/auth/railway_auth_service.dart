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
      );
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    throw const AuthException('Google login is not supported in Railway mode.');
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
  }
}
