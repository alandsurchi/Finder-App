import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../app/di/app_providers.dart';

enum AuthStatus { loading, authenticated, unauthenticated, unverified }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final Failure? failure;

  const AuthState._({required this.status, this.userId, this.failure});

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(String userId)
    : this._(status: AuthStatus.authenticated, userId: userId);

  const AuthState.unverified(String userId)
    : this._(status: AuthStatus.unverified, userId: userId);

  const AuthState.unauthenticated([Failure? failure])
    : this._(status: AuthStatus.unauthenticated, failure: failure);

  bool get isSignedIn =>
      status == AuthStatus.authenticated || status == AuthStatus.unverified;
}

class AuthStateController extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthStateController({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const AuthState.loading()) {
    _init();
  }

  /// On launch: if a token is stored, ask the server whether it is still
  /// valid. A rejected token signs the user out; being offline falls back to
  /// the claims inside the token so the app still opens.
  Future<void> _init() async {
    final token = _apiClient.token;
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    final claims = _decodeClaims(token);
    final uidFromToken = claims?['userId']?.toString() ?? '';
    if (uidFromToken.isEmpty) {
      await _apiClient.clearToken();
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final res = await _apiClient.get('/auth/me');
      final map = res is Map ? Map<String, dynamic>.from(res) : const {};
      final uid = map['uid']?.toString() ?? uidFromToken;
      final verified = map['isVerified'] as bool? ?? true;
      state = verified ? AuthState.authenticated(uid) : AuthState.unverified(uid);
    } on ApiException catch (e) {
      if (e.isUnauthorized || e.isNotFound) {
        await _apiClient.clearToken();
        state = const AuthState.unauthenticated();
      } else {
        _fromClaims(claims!, uidFromToken);
      }
    } catch (_) {
      // Offline: trust the token until the server can be reached.
      _fromClaims(claims!, uidFromToken);
    }
  }

  void _fromClaims(Map<String, dynamic> claims, String uid) {
    final verified = claims['isVerified'] as bool? ?? true;
    state = verified ? AuthState.authenticated(uid) : AuthState.unverified(uid);
  }

  static Map<String, dynamic>? _decodeClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = jsonDecode(utf8.decode(base64.decode(payload)));
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  void setAuthenticated(String userId) {
    state = AuthState.authenticated(userId);
  }

  void setUnverified(String userId) {
    state = AuthState.unverified(userId);
  }

  void setUnauthenticated([Failure? failure]) {
    state = AuthState.unauthenticated(failure);
  }

  /// Called when the server rejected the stored token.
  void sessionExpired() {
    if (state.status == AuthStatus.unauthenticated) return;
    state = const AuthState.unauthenticated(
      Failure(
        message: 'Your session has expired. Please sign in again.',
        type: FailureType.auth,
      ),
    );
  }

  void setLoading() {
    state = const AuthState.loading();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>(
  (ref) => AuthStateController(apiClient: ref.read(apiClientProvider)),
);

/// The signed-in user's id, or null.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).userId,
);
