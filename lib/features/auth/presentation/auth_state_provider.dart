import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failure.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final Failure? failure;

  const AuthState._({required this.status, this.userId, this.failure});

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(String userId)
    : this._(status: AuthStatus.authenticated, userId: userId);

  const AuthState.unauthenticated([Failure? failure])
    : this._(status: AuthStatus.unauthenticated, failure: failure);
}

class AuthStateController extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;

  AuthStateController({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(
        (auth ?? FirebaseAuth.instance).currentUser == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(
                (auth ?? FirebaseAuth.instance).currentUser!.uid,
              ),
      ) {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user.uid);
      }
    });
  }

  void setAuthenticated(String userId) {
    state = AuthState.authenticated(userId);
  }

  void setUnauthenticated([Failure? failure]) {
    state = AuthState.unauthenticated(failure);
  }

  void setLoading() {
    state = const AuthState.loading();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>(
  (ref) => AuthStateController(),
);
