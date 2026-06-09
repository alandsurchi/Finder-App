class Post {
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

  const Post({
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
}
