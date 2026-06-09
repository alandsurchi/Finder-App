class UserDto {
  final String id;
  final String fullName;
  final String nickName;
  final String email;
  final String phone;
  final String address;
  final String job;
  final String avatarUrl;
  final int? createdAtMs;

  const UserDto({
    required this.id,
    required this.fullName,
    required this.nickName,
    required this.email,
    required this.phone,
    required this.address,
    required this.job,
    required this.avatarUrl,
    this.createdAtMs,
  });

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName'] as String? ?? '',
      nickName: map['nickName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      job: map['job'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      createdAtMs: map['createdAtMs'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'nickName': nickName,
      'email': email,
      'phone': phone,
      'address': address,
      'job': job,
      'avatarUrl': avatarUrl,
      'createdAtMs': createdAtMs,
    };
  }
}
