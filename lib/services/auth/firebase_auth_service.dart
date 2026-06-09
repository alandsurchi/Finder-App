import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/errors/exceptions.dart';
import '../../features/auth/domain/auth_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const FirebaseAuthService({
    required fb.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  @override
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Authentication failed. Please try again.');
      }
      await _ensureUserProfile(user);
      return _mapUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageForAuthCode(e.code), code: e.code);
    } on FirebaseException catch (e) {
      throw AuthException(
        'Unable to authenticate right now. Please try again later.',
        code: e.code,
      );
    }
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      await _ensureUserProfile(user);
      return _mapUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageForAuthCode(e.code), code: e.code);
    } on FirebaseException catch (e) {
      throw AuthException(
        'Unable to create account right now. Please try again later.',
        code: e.code,
      );
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    throw const AuthException(
      'Google sign-in is not configured yet for this app.',
      code: 'google_not_configured',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException('Unable to log out right now.', code: e.code);
    }
  }

  Future<void> _ensureUserProfile(fb.User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final name = user.displayName?.trim();
    final emailPrefix = user.email?.split('@').first ?? 'finder_user';

    await docRef.set({
      'id': user.uid,
      'fullName': (name == null || name.isEmpty) ? emailPrefix : name,
      'nickName': emailPrefix,
      'email': user.email ?? '',
      'avatarUrl': user.photoURL ?? '',
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  AuthUser _mapUser(fb.User user) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  String _messageForAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
