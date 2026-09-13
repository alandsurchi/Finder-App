import '../core/utils/result.dart';
import '../features/profile/domain/blocked_user.dart';
import '../features/profile/domain/notification_settings.dart';
import '../features/profile/domain/privacy_settings.dart';
import '../features/profile/domain/verification_status.dart';
import '../models/user_model.dart';

abstract class ProfileRepository {
  Future<Result<UserModel>> getProfile();

  Future<Result<UserModel>> updateProfile(UserModel profile);

  Future<Result<PrivacySettings>> getPrivacySettings();

  Future<Result<PrivacySettings>> updatePrivacySettings(PrivacySettings settings);

  Future<Result<NotificationSettings>> getNotificationSettings();

  Future<Result<NotificationSettings>> updateNotificationSettings(
      NotificationSettings settings);

  Future<Result<List<BlockedUser>>> getBlockedUsers();

  Future<Result<void>> blockUser(String userId);

  Future<Result<void>> unblockUser(String userId);

  Future<Result<VerificationStatus>> getVerificationStatus();

  Future<Result<VerificationStatus>> submitVerification(VerificationRequest request);
}
