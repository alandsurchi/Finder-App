import '../core/network/api_client.dart';
import '../models/user_model.dart';

/// A row from `GET /users/search`.
class UserSummary {
  final String uid;
  final String fullName;
  final String nickName;
  final String avatarUrl;
  final bool identityVerified;

  const UserSummary({
    required this.uid,
    required this.fullName,
    this.nickName = '',
    this.avatarUrl = '',
    this.identityVerified = false,
  });

  String get displayName => fullName.isNotEmpty ? fullName : nickName;

  factory UserSummary.fromApi(Map<String, dynamic> map) => UserSummary(
        uid: map['uid']?.toString() ?? '',
        fullName: map['fullName']?.toString() ?? '',
        nickName: map['nickName']?.toString() ?? '',
        avatarUrl: map['avatarUrl']?.toString() ?? '',
        identityVerified: map['identityVerified'] == true,
      );
}

/// Other users: public profiles, search, block / unblock.
class UserService {
  final ApiClient _apiClient;

  UserService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<UserModel> fetchProfile(String userId) async {
    final res = await _apiClient.get('/profile/$userId');
    return UserModel.fromApi(Map<String, dynamic>.from(res as Map));
  }

  Future<List<UserSummary>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final res = await _apiClient.get('/users/search?q=${Uri.encodeQueryComponent(q)}');
    final list = res as List<dynamic>? ?? [];
    return list
        .map((e) => UserSummary.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> block(String userId) =>
      _apiClient.post('/profile/blocked', {'blockedUserId': userId});

  Future<void> unblock(String userId) =>
      _apiClient.delete('/profile/blocked/$userId');
}
