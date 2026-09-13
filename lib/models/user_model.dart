import '../core/utils/timestamp.dart';

class UserModel {
  final String uid;
  final String email;
  final Timestamp createdAt;
  final String fullName;
  final String nickName;
  final String phone;
  final String address;
  final String job;
  final String avatarUrl;
  final bool identityVerified;
  final int postsCount;

  UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.fullName = '',
    this.nickName = '',
    this.phone = '',
    this.address = '',
    this.job = '',
    this.avatarUrl = '',
    this.identityVerified = false,
    this.postsCount = 0,
  });

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (nickName.trim().isNotEmpty) return nickName.trim();
    return 'Finder User';
  }

  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      createdAt: Timestamp.now(),
    );
  }

  /// Builds a user from `/profile`, `/profile/:id` or `/auth/me` responses.
  factory UserModel.fromApi(Map<String, dynamic> map) {
    final createdAtMs = (map['createdAtMs'] as num?)?.toInt() ??
        (map['memberSinceMs'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      nickName: map['nickName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      job: map['job']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      identityVerified: map['identityVerified'] == true,
      postsCount: (map['postsCount'] as num?)?.toInt() ?? 0,
      createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      email: map['email'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      fullName: map['fullName'] ?? '',
      nickName: map['nickName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      job: map['job'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      identityVerified: map['identityVerified'] ?? false,
      postsCount: map['postsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt,
      'fullName': fullName,
      'nickName': nickName,
      'phone': phone,
      'address': address,
      'job': job,
      'avatarUrl': avatarUrl,
      'identityVerified': identityVerified,
      'postsCount': postsCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    Timestamp? createdAt,
    String? fullName,
    String? nickName,
    String? phone,
    String? address,
    String? job,
    String? avatarUrl,
    bool? identityVerified,
    int? postsCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      nickName: nickName ?? this.nickName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      job: job ?? this.job,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      identityVerified: identityVerified ?? this.identityVerified,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}
