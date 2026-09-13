import '../core/utils/relative_time.dart';
import '../core/utils/timestamp.dart';

/// A lost or found post as the app sees it.
///
/// [ItemModel.fromApi] / [toApiBody] are the only two places that know the
/// backend field names (`imageUrl`, `status`, `ownerVerified`, …).
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
  final String ownerAvatarUrl;
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
    this.ownerAvatarUrl = '',
    this.ownerTrustScore,
    this.isResolved = false,
  }) : createdAt = createdAt ?? Timestamp.now();

  bool get hasReward => reward != null && reward!.trim().isNotEmpty;
  bool get hasImage => imagePath.trim().isNotEmpty;

  /// Builds an item from a backend post object.
  factory ItemModel.fromApi(Map<String, dynamic> map) {
    final createdAtMs = (map['createdAtMs'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    final reward = map['reward']?.toString();
    return ItemModel(
      id: map['id']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      isLost: map['isLost'] == true,
      reward: (reward == null || reward.trim().isEmpty) ? null : reward,
      location: map['location']?.toString() ?? '',
      imagePath: map['imageUrl']?.toString() ?? '',
      lostOn: map['lostOn']?.toString(),
      ownerName: map['ownerName']?.toString(),
      ownerAvatarUrl: map['ownerAvatarUrl']?.toString() ?? '',
      isVerified: map['ownerVerified'] == true,
      isResolved: map['status']?.toString() == 'resolved',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
      timeAgo: relativeTime(createdAtMs),
    );
  }

  /// The JSON body for `POST /posts` and `PUT /posts/:id`.
  Map<String, dynamic> toApiBody() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'isLost': isLost,
      'reward': reward,
      'location': location,
      'imageUrl': imagePath,
      'lostOn': lostOn,
    };
  }

  /// Legacy map constructor kept for local sample data and previews.
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
      ownerAvatarUrl: map['ownerAvatarUrl'] ?? '',
      ownerTrustScore: map['ownerTrustScore']?.toDouble(),
      isResolved: map['isResolved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
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
      'ownerAvatarUrl': ownerAvatarUrl,
      'ownerTrustScore': ownerTrustScore,
      'isResolved': isResolved,
    };
  }

  ItemModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    Timestamp? createdAt,
    String? location,
    String? timeAgo,
    String? imagePath,
    bool? isLost,
    String? reward,
    bool clearReward = false,
    bool? isVerified,
    String? category,
    String? lostOn,
    String? lastSeenAt,
    String? ownerName,
    String? ownerAvatarUrl,
    double? ownerTrustScore,
    bool? isResolved,
  }) {
    return ItemModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      timeAgo: timeAgo ?? this.timeAgo,
      imagePath: imagePath ?? this.imagePath,
      isLost: isLost ?? this.isLost,
      reward: clearReward ? null : (reward ?? this.reward),
      isVerified: isVerified ?? this.isVerified,
      category: category ?? this.category,
      lostOn: lostOn ?? this.lostOn,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerTrustScore: ownerTrustScore ?? this.ownerTrustScore,
      isResolved: isResolved ?? this.isResolved,
    );
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
