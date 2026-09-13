class BlockedUser {
  final String id;
  final String name;
  final String avatarLabel;
  final String avatarUrl;

  const BlockedUser({
    required this.id,
    required this.name,
    required this.avatarLabel,
    this.avatarUrl = '',
  });
}
