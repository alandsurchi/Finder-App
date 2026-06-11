class AuthUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isVerified = true,
  });
}

