import '../../core/utils/timestamp.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../features/profile/domain/blocked_user.dart';
import '../../features/profile/domain/privacy_settings.dart';
import '../../models/user_model.dart';
import '../profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  static const PrivacySettings _defaultSettings = PrivacySettings(
    showProfile: true,
    allowMessages: true,
    showLocation: false,
    hidePhone: true,
  );

  const ProfileRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<UserModel>> getProfile() async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view your profile.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final res = await _apiClient.get('/profile');
      final map = Map<String, dynamic>.from(res);
      final createdAtMs = map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      
      final profile = UserModel(
        uid: map['uid']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        fullName: map['fullName']?.toString() ?? '',
        nickName: map['nickName']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        address: map['address']?.toString() ?? '',
        job: map['job']?.toString() ?? '',
        avatarUrl: map['avatarUrl']?.toString() ?? '',
        createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
      );

      return Result.success(profile);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load profile: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<UserModel>> updateProfile(UserModel profile) async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update your profile.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final payload = {
        'fullName': profile.fullName,
        'nickName': profile.nickName,
        'phone': profile.phone,
        'address': profile.address,
        'job': profile.job,
        'avatarUrl': profile.avatarUrl,
      };

      final res = await _apiClient.put('/profile', payload);
      final map = Map<String, dynamic>.from(res);
      final createdAtMs = map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch;

      final updated = UserModel(
        uid: map['uid']?.toString() ?? profile.uid,
        email: map['email']?.toString() ?? profile.email,
        fullName: map['fullName']?.toString() ?? profile.fullName,
        nickName: map['nickName']?.toString() ?? profile.nickName,
        phone: map['phone']?.toString() ?? profile.phone,
        address: map['address']?.toString() ?? profile.address,
        job: map['job']?.toString() ?? profile.job,
        avatarUrl: map['avatarUrl']?.toString() ?? profile.avatarUrl,
        createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
      );

      return Result.success(updated);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update profile: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<PrivacySettings>> getPrivacySettings() async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view privacy settings.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final res = await _apiClient.get('/profile/privacy');
      final map = Map<String, dynamic>.from(res);

      final settings = PrivacySettings(
        showProfile: map['showProfile'] as bool? ?? _defaultSettings.showProfile,
        allowMessages: map['allowMessages'] as bool? ?? _defaultSettings.allowMessages,
        showLocation: map['showLocation'] as bool? ?? _defaultSettings.showLocation,
        hidePhone: map['hidePhone'] as bool? ?? _defaultSettings.hidePhone,
      );

      return Result.success(settings);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load privacy settings: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<PrivacySettings>> updatePrivacySettings(
    PrivacySettings settings,
  ) async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update privacy settings.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final payload = {
        'showProfile': settings.showProfile,
        'allowMessages': settings.allowMessages,
        'showLocation': settings.showLocation,
        'hidePhone': settings.hidePhone,
      };

      await _apiClient.put('/profile/privacy', payload);
      return Result.success(settings);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update privacy settings: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<List<BlockedUser>>> getBlockedUsers() async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view blocked users.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final res = await _apiClient.get('/profile/blocked');
      final list = res as List<dynamic>;

      final users = list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final name = map['name']?.toString() ?? 'Unknown User';
        return BlockedUser(
          id: map['id']?.toString() ?? '',
          name: name,
          avatarLabel: map['avatarLabel']?.toString() ?? _avatarLabel(name),
        );
      }).toList();

      return Result.success(users);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load blocked users: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<void>> unblockUser(String userId) async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to update blocked users.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      await _apiClient.delete('/profile/blocked/$userId');
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to unblock user: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  String _avatarLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
