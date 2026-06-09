import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password, {
    String fullName = '',
    String phone = '',
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final resolvedName =
            fullName.isNotEmpty ? fullName : email.split('@').first;
        final resolvedNick = resolvedName.replaceAll(' ', '').toLowerCase();

        // Set display name in Firebase Auth so it's available everywhere
        await credential.user!.updateDisplayName(resolvedName);

        // Save full profile to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'fullName': resolvedName,
          'nickName': resolvedNick,
          'phone': phone,
          'address': '',
          'job': '',
          'avatarUrl': '',
        });
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential?> loginWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
