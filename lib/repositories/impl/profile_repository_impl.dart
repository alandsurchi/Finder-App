import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../features/profile/domain/blocked_user.dart';
import '../../features/profile/domain/notification_settings.dart';
import '../../features/profile/domain/privacy_settings.dart';
import '../../features/profile/domain/verification_status.dart';
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

  Failure? _requireAuth(String action) => _apiClient.isAuthenticated
      ? null
      : Failure(message: 'Please log in to $action.', type: FailureType.auth);

  /// Runs [call] and maps any thrown error to a [Failure].
  Future<Result<T>> _guard<T>(
    String action,
    Future<T> Function() call, {
    required String fallback,
  }) async {
    final auth = _requireAuth(action);
    if (auth != null) return Result.failure(auth);
    try {
      return Result.success(await call());
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: fallback));
    }
  }

  Map<String, dynamic> _map(dynamic res) =>
      Map<String, dynamic>.from(res as Map);

  @override
  Future<Result<UserModel>> getProfile() => _guard(
        'view your profile',
        () async => UserModel.fromApi(_map(await _apiClient.get('/profile'))),
        fallback: 'Unable to load your profile.',
      );

  @override
  Future<Result<UserModel>> updateProfile(UserModel profile) => _guard(
        'update your profile',
        () async {
          final res = await _apiClient.put('/profile', {
            'fullName': profile.fullName,
            'nickName': profile.nickName,
            'phone': profile.phone,
            'address': profile.address,
            'job': profile.job,
            'avatarUrl': profile.avatarUrl,
          });
          final updated = UserModel.fromApi(_map(res));
          // The PUT response has no verification flag; keep what we knew.
          return updated.copyWith(
            identityVerified: profile.identityVerified || updated.identityVerified,
            postsCount: profile.postsCount,
          );
        },
        fallback: 'Unable to update your profile.',
      );

  @override
  Future<Result<PrivacySettings>> getPrivacySettings() => _guard(
        'view privacy settings',
        () async {
          final map = _map(await _apiClient.get('/profile/privacy'));
          return PrivacySettings(
            showProfile: map['showProfile'] as bool? ?? _defaultSettings.showProfile,
            allowMessages: map['allowMessages'] as bool? ?? _defaultSettings.allowMessages,
            showLocation: map['showLocation'] as bool? ?? _defaultSettings.showLocation,
            hidePhone: map['hidePhone'] as bool? ?? _defaultSettings.hidePhone,
          );
        },
        fallback: 'Unable to load privacy settings.',
      );

  @override
  Future<Result<PrivacySettings>> updatePrivacySettings(
    PrivacySettings settings,
  ) =>
      _guard(
        'update privacy settings',
        () async {
          await _apiClient.put('/profile/privacy', {
            'showProfile': settings.showProfile,
            'allowMessages': settings.allowMessages,
            'showLocation': settings.showLocation,
            'hidePhone': settings.hidePhone,
          });
          return settings;
        },
        fallback: 'Unable to update privacy settings.',
      );

  @override
  Future<Result<NotificationSettings>> getNotificationSettings() => _guard(
        'view notification settings',
        () async => NotificationSettings.fromApi(
            _map(await _apiClient.get('/profile/notification-settings'))),
        fallback: 'Unable to load notification settings.',
      );

  @override
  Future<Result<NotificationSettings>> updateNotificationSettings(
    NotificationSettings settings,
  ) =>
      _guard(
        'update notification settings',
        () async => NotificationSettings.fromApi(_map(await _apiClient.put(
            '/profile/notification-settings', settings.toApiBody()))),
        fallback: 'Unable to update notification settings.',
      );

  @override
  Future<Result<List<BlockedUser>>> getBlockedUsers() => _guard(
        'view blocked users',
        () async {
          final list = await _apiClient.get('/profile/blocked') as List<dynamic>? ?? [];
          return list.map((item) {
            final map = _map(item);
            final name = map['name']?.toString() ?? 'Unknown User';
            return BlockedUser(
              id: map['id']?.toString() ?? '',
              name: name,
              avatarLabel: map['avatarLabel']?.toString() ?? _avatarLabel(name),
              avatarUrl: map['avatarUrl']?.toString() ?? '',
            );
          }).toList();
        },
        fallback: 'Unable to load blocked users.',
      );

  @override
  Future<Result<void>> blockUser(String userId) => _guard(
        'block users',
        () => _apiClient.post('/profile/blocked', {'blockedUserId': userId}),
        fallback: 'Unable to block this user.',
      );

  @override
  Future<Result<void>> unblockUser(String userId) => _guard(
        'update blocked users',
        () => _apiClient.delete('/profile/blocked/$userId'),
        fallback: 'Unable to unblock this user.',
      );

  @override
  Future<Result<void>> deleteAccount({String? password, String? confirm}) => _guard(
        'delete your account',
        () => _apiClient.deleteWithBody('/profile', {
          if (password != null) 'password': password,
          if (confirm != null) 'confirm': confirm,
        }),
        fallback: 'Unable to delete your account.',
      );

  @override
  Future<Result<VerificationStatus>> getVerificationStatus() => _guard(
        'check verification',
        () async => VerificationStatus.fromApi(
            _map(await _apiClient.get('/profile/verification'))),
        fallback: 'Unable to load verification status.',
      );

  @override
  Future<Result<VerificationStatus>> submitVerification(
    VerificationRequest request,
  ) =>
      _guard(
        'submit verification',
        () async => VerificationStatus.fromApi(_map(
            await _apiClient.post('/profile/verification', request.toApiBody()))),
        fallback: 'Unable to submit your verification.',
      );

  String _avatarLabel(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
