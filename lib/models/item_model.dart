import '../core/utils/relative_time.dart';
import '../core/utils/timestamp.dart';
import '../features/location/place.dart';

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

  /// Always current and in the app language (never cached).
  String get timeAgo => relativeTime(createdAt.millisecondsSinceEpoch);
  final String location;
  final String imagePath;
  final bool isLost;
  final String? reward;
  final bool isVerified;
  /// The owner is a Finder administrator (staff mark).
  final bool ownerIsAdmin;
  final String category;
  final String? lostOn;
  final double? latitude;
  final double? longitude;
  final String? lastSeenAt;
  final String? ownerName;
  final String ownerAvatarUrl;
  final double? ownerTrustScore;
  final bool isResolved;
  /// pending | active | resolved | rejected | expired (see the review flow).
  final String status;
  /// Text as the owner wrote it; [title]/[description] may be translations.
  final String originalTitle;
  final String originalDescription;
  /// Language the owner wrote in (en | ar | ckb | other), null when unknown.
  final String? sourceLang;
  /// Why an admin rejected the post; only set while [isRejected].
  final String? rejectionReason;
  /// Admin-only AI pre-check (0-100) and its reasons; null when not checked.
  final int? aiRisk;
  final List<String> aiReasons;
  /// Public link to this post (`/p/<id>` on the API host); empty offline.
  final String shareUrl;

  ItemModel({
    required this.id,
    this.ownerId = '',
    required this.title,
    required this.description,
    Timestamp? createdAt,
    required this.location,
    required this.imagePath,
    required this.isLost,
    this.reward,
    this.isVerified = false,
    this.ownerIsAdmin = false,
    required this.category,
    this.lostOn,
    this.latitude,
    this.longitude,
    this.lastSeenAt,
    this.ownerName,
    this.ownerAvatarUrl = '',
    this.ownerTrustScore,
    this.isResolved = false,
    String? status,
    String? originalTitle,
    String? originalDescription,
    this.sourceLang,
    this.rejectionReason,
    this.aiRisk,
    this.aiReasons = const [],
    this.shareUrl = '',
  })  : createdAt = createdAt ?? Timestamp.now(),
        status = status ?? (isResolved ? 'resolved' : 'active'),
        originalTitle = originalTitle ?? title,
        originalDescription = originalDescription ?? description;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';
  /// Visible to other members (live or returned).
  bool get isPublic => status == 'active' || status == 'resolved';
  /// The post is still in the review flow (not yet live).
  bool get isUnderReview => isPending || isRejected;
  /// The text shown is a translation of what the owner wrote.
  bool get isTranslated => title != originalTitle || description != originalDescription;

  bool get hasReward => reward != null && reward!.trim().isNotEmpty;
  bool get hasImage => imagePath.trim().isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;

  /// The pinned place, when the post carries coordinates.
  Place? get place => hasCoordinates
      ? Place(latitude: latitude!, longitude: longitude!, label: location)
      : null;

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
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      ownerName: map['ownerName']?.toString(),
      ownerAvatarUrl: map['ownerAvatarUrl']?.toString() ?? '',
      isVerified: map['ownerVerified'] == true,
      ownerIsAdmin: map['ownerIsAdmin'] == true,
      isResolved: map['status']?.toString() == 'resolved',
      status: map['status']?.toString() ?? 'active',
      originalTitle: map['originalTitle']?.toString(),
      originalDescription: map['originalDescription']?.toString(),
      sourceLang: map['sourceLang']?.toString(),
      rejectionReason: map['rejectionReason']?.toString(),
      aiRisk: (map['aiRisk'] as num?)?.toInt(),
      aiReasons: (map['aiReasons'] is List)
          ? (map['aiReasons'] as List).map((e) => e.toString()).toList()
          : const [],
      shareUrl: map['shareUrl']?.toString() ?? '',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
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
      'latitude': latitude,
      'longitude': longitude,
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
      imagePath: map['imagePath'] ?? '',
      isLost: map['isLost'] ?? true,
      reward: map['reward'],
      isVerified: map['isVerified'] ?? false,
      category: map['category'] ?? 'All Items',
      lostOn: map['lostOn'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
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
      'imagePath': imagePath,
      'isLost': isLost,
      'reward': reward,
      'isVerified': isVerified,
      'category': category,
      'lostOn': lostOn,
      'latitude': latitude,
      'longitude': longitude,
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
    String? imagePath,
    bool? isLost,
    String? reward,
    bool clearReward = false,
    bool? isVerified,
    bool? ownerIsAdmin,
    String? category,
    String? lostOn,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
    String? lastSeenAt,
    String? ownerName,
    String? ownerAvatarUrl,
    double? ownerTrustScore,
    bool? isResolved,
    String? status,
    String? rejectionReason,
    bool clearRejectionReason = false,
    String? shareUrl,
  }) {
    return ItemModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      isLost: isLost ?? this.isLost,
      reward: clearReward ? null : (reward ?? this.reward),
      isVerified: isVerified ?? this.isVerified,
      ownerIsAdmin: ownerIsAdmin ?? this.ownerIsAdmin,
      category: category ?? this.category,
      lostOn: lostOn ?? this.lostOn,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerTrustScore: ownerTrustScore ?? this.ownerTrustScore,
      isResolved: isResolved ?? (status != null ? status == 'resolved' : this.isResolved),
      status: status ?? (isResolved == null ? this.status : (isResolved ? 'resolved' : 'active')),
      originalTitle: title == null ? originalTitle : null,
      originalDescription: description == null ? originalDescription : null,
      sourceLang: sourceLang,
      rejectionReason: clearRejectionReason ? null : (rejectionReason ?? this.rejectionReason),
      aiRisk: aiRisk,
      aiReasons: aiReasons,
      shareUrl: shareUrl ?? this.shareUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.title == title &&
        other.description == description &&
        other.createdAt.millisecondsSinceEpoch ==
            createdAt.millisecondsSinceEpoch &&
        other.location == location &&
        other.imagePath == imagePath &&
        other.isLost == isLost &&
        other.reward == reward &&
        other.isVerified == isVerified &&
        other.ownerIsAdmin == ownerIsAdmin &&
        other.category == category &&
        other.lostOn == lostOn &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.ownerName == ownerName &&
        other.ownerAvatarUrl == ownerAvatarUrl &&
        other.isResolved == isResolved &&
        other.status == status &&
        other.rejectionReason == rejectionReason;
  }

  @override
  int get hashCode => Object.hash(
        id,
        ownerId,
        title,
        description,
        createdAt.millisecondsSinceEpoch,
        location,
        imagePath,
        isLost,
        reward,
        isVerified,
        category,
        lostOn,
        latitude,
        longitude,
        ownerName,
        ownerAvatarUrl,
        isResolved,
        status,
        rejectionReason,
      );

  factory ItemModel.empty() {
    return ItemModel(
      id: '',
      ownerId: '',
      title: '',
      description: '',
      createdAt: Timestamp.now(),
      location: '',
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
