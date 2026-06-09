import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      createdAt: Timestamp.now(),
      fullName: '',
      nickName: '',
      phone: '',
      address: '',
      job: '',
      avatarUrl: '',
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
    );
  }
}
