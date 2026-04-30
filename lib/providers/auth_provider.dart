import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Canonical authServiceProvider — used across the whole app
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Live stream of the Firebase Auth user state
final authUserStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
