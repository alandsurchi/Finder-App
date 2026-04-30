class PostDto {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isLost;
  final String? reward;
  final String ownerId;
  final String location;
  final String imageUrl;
  final int? createdAtMs;
  final int? updatedAtMs;
  final String status;

  const PostDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isLost,
    required this.reward,
    required this.ownerId,
    required this.location,
    required this.imageUrl,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.status,
  });

  factory PostDto.fromMap(Map<String, dynamic> map) {
    return PostDto(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      isLost: map['isLost'] as bool? ?? true,
      reward: map['reward'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      location: map['location'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      createdAtMs: map['createdAtMs'] as int?,
      updatedAtMs: map['updatedAtMs'] as int?,
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isLost': isLost,
      'reward': reward,
      'ownerId': ownerId,
      'location': location,
      'imageUrl': imageUrl,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
      'status': status,
    };
  }
}
