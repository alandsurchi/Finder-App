class CreatePostInput {
  final String title;
  final String description;
  final String category;
  final bool isLost;
  final String? reward;
  final String location;
  final String imagePath;

  const CreatePostInput({
    required this.title,
    required this.description,
    required this.category,
    required this.isLost,
    required this.reward,
    required this.location,
    required this.imagePath,
  });
}
