import '../core/utils/result.dart';
import '../features/profile/domain/blocked_user.dart';
import '../features/profile/domain/privacy_settings.dart';
import '../models/user_model.dart';

abstract class ProfileRepository {
  Future<Result<UserModel>> getProfile();

  Future<Result<UserModel>> updateProfile(UserModel profile);

  Future<Result<PrivacySettings>> getPrivacySettings();

  Future<Result<PrivacySettings>> updatePrivacySettings(PrivacySettings settings);

  Future<Result<List<BlockedUser>>> getBlockedUsers();

  Future<Result<void>> unblockUser(String userId);
}
