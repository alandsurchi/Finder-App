import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final Timestamp createdAt;
  final String location;
  final String timeAgo;
  final String imagePath;
  final bool isLost;
  final String? reward;
  final bool isVerified;
  final String category;
  final String? lostOn;
  final String? lastSeenAt;
  final String? ownerName;
  final double? ownerTrustScore;
  final bool isResolved;

  ItemModel({
    required this.id,
    this.ownerId = '',
    required this.title,
    required this.description,
    Timestamp? createdAt,
    required this.location,
    required this.timeAgo,
    required this.imagePath,
    required this.isLost,
    this.reward,
    this.isVerified = false,
    required this.category,
    this.lostOn,
    this.lastSeenAt,
    this.ownerName,
    this.ownerTrustScore,
    this.isResolved = false,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory ItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ItemModel(
      id: documentId,
      ownerId: map['ownerId'] ?? map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      location: map['location'] ?? '',
      timeAgo: map['timeAgo'] ?? 'Just now',
      imagePath: map['imagePath'] ?? '',
      isLost: map['isLost'] ?? true,
      reward: map['reward'],
      isVerified: map['isVerified'] ?? false,
      category: map['category'] ?? 'All Items',
      lostOn: map['lostOn'],
      lastSeenAt: map['lastSeenAt'],
      ownerName: map['ownerName'],
      ownerTrustScore: map['ownerTrustScore']?.toDouble(),
      isResolved: map['isResolved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'userId': ownerId, // Keep for backwards compatibility
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'location': location,
      'timeAgo': timeAgo,
      'imagePath': imagePath,
      'isLost': isLost,
      'reward': reward,
      'isVerified': isVerified,
      'category': category,
      'lostOn': lostOn,
      'lastSeenAt': lastSeenAt,
      'ownerName': ownerName,
      'ownerTrustScore': ownerTrustScore,
      'isResolved': isResolved,
    };
  }

  factory ItemModel.empty() {
    return ItemModel(
      id: '',
      ownerId: '',
      title: '',
      description: '',
      createdAt: Timestamp.now(),
      location: '',
      timeAgo: '',
      imagePath: '',
      isLost: true,
      reward: null,
      isVerified: false,
      category: '',
      lostOn: null,
      lastSeenAt: null,
      ownerName: null,
      ownerTrustScore: null,
      isResolved: false,
    );
  }
}
