import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../features/profile/domain/blocked_user.dart';
import '../../features/profile/domain/privacy_settings.dart';
import '../../models/user_model.dart';
import '../profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const PrivacySettings _defaultSettings = PrivacySettings(
    showProfile: true,
    allowMessages: true,
    showLocation: false,
    hidePhone: true,
  );

  const ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Result<UserModel>> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view your profile.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final docRef = _users.doc(user.uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        final created = _defaultProfile(user);
        await docRef.set(_toProfileMap(created), SetOptions(merge: true));
        return Result.success(created);
      }

      final profile = _fromProfileMap(snapshot.data() ?? const {}, user);
      return Result.success(profile);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load your profile right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<UserModel>> updateProfile(UserModel profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update your profile.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final merged = profile.copyWith(
        uid: user.uid,
        email: profile.email.isEmpty ? (user.email ?? '') : profile.email,
      );

      await _users
          .doc(user.uid)
          .set(_toProfileMap(merged), SetOptions(merge: true));
      return Result.success(merged);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update your profile right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<PrivacySettings>> getPrivacySettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view privacy settings.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final docRef = _privacyDoc(user.uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set(_toPrivacyMap(_defaultSettings));
        return Result.success(_defaultSettings);
      }

      return Result.success(_fromPrivacyMap(snapshot.data() ?? const {}));
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load privacy settings right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<PrivacySettings>> updatePrivacySettings(
    PrivacySettings settings,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update privacy settings.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      await _privacyDoc(
        user.uid,
      ).set(_toPrivacyMap(settings), SetOptions(merge: true));
      return Result.success(settings);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update privacy settings right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<List<BlockedUser>>> getBlockedUsers() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view blocked users.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final snapshot = await _blockedUsers(user.uid).orderBy('name').get();
      final users = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final name = data['name']?.toString() ?? 'Unknown User';
            return BlockedUser(
              id: doc.id,
              name: name,
              avatarLabel: _avatarLabel(name),
            );
          })
          .toList(growable: false);
      return Result.success(users);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load blocked users right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<void>> unblockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update blocked users.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      await _blockedUsers(user.uid).doc(userId).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to unblock user right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _privacyDoc(String userId) {
    return _users.doc(userId).collection('settings').doc('privacy');
  }

  CollectionReference<Map<String, dynamic>> _blockedUsers(String userId) {
    return _users.doc(userId).collection('blockedUsers');
  }

  UserModel _defaultProfile(User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final baseName = firebaseUser.displayName?.trim();
    final nick = email.contains('@') ? email.split('@').first : 'finder_user';

    return UserModel(
      uid: firebaseUser.uid,
      createdAt: Timestamp.now(),
      fullName: (baseName == null || baseName.isEmpty) ? nick : baseName,
      nickName: nick,
      email: email,
      phone: '',
      address: '',
      job: '',
      avatarUrl: firebaseUser.photoURL ?? '',
    );
  }

  UserModel _fromProfileMap(Map<String, dynamic> map, User user) {
    final fallback = _defaultProfile(user);
    return UserModel(
      uid: map['uid']?.toString() ?? fallback.uid,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      fullName: map['fullName']?.toString() ?? fallback.fullName,
      nickName: map['nickName']?.toString() ?? fallback.nickName,
      email: map['email']?.toString() ?? fallback.email,
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      job: map['job']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? fallback.avatarUrl,
    );
  }

  Map<String, dynamic> _toProfileMap(UserModel profile) {
    return {
      'uid': profile.uid,
      'fullName': profile.fullName,
      'nickName': profile.nickName,
      'email': profile.email,
      'phone': profile.phone,
      'address': profile.address,
      'job': profile.job,
      'avatarUrl': profile.avatarUrl,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  PrivacySettings _fromPrivacyMap(Map<String, dynamic> map) {
    return PrivacySettings(
      showProfile: map['showProfile'] as bool? ?? _defaultSettings.showProfile,
      allowMessages:
          map['allowMessages'] as bool? ?? _defaultSettings.allowMessages,
      showLocation:
          map['showLocation'] as bool? ?? _defaultSettings.showLocation,
      hidePhone: map['hidePhone'] as bool? ?? _defaultSettings.hidePhone,
    );
  }

  Map<String, dynamic> _toPrivacyMap(PrivacySettings settings) {
    return {
      'showProfile': settings.showProfile,
      'allowMessages': settings.allowMessages,
      'showLocation': settings.showLocation,
      'hidePhone': settings.hidePhone,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  String _avatarLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
