import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

class AuthStateController extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthStateController({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const AuthState.loading()) {
    _init();
  }

  void _init() {
    final token = _apiClient.token;
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Base64URL decode
          var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
          switch (normalized.length % 4) {
            case 2:
              normalized += '==';
              break;
            case 3:
              normalized += '=';
              break;
          }
          final decoded = utf8.decode(base64.decode(normalized));
          final map = jsonDecode(decoded);
          final uid = map['userId']?.toString() ?? '';
          final isVerified = map['isVerified'] as bool? ?? true;
          if (uid.isNotEmpty) {
            if (isVerified) {
              state = AuthState.authenticated(uid);
            } else {
              state = AuthState.unverified(uid);
            }
            return;
          }
        }
      } catch (_) {}
    }
    state = const AuthState.unauthenticated();
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

  void setLoading() {
    state = const AuthState.loading();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>(
  (ref) => AuthStateController(apiClient: ref.read(apiClientProvider)),
);
