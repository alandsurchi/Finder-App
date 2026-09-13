import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/saved_items_repository.dart';
import '../../repositories/impl/auth_repository_impl.dart';
import '../../repositories/impl/notification_repository_impl.dart';
import '../../repositories/impl/profile_repository_impl.dart';
import '../../repositories/impl/saved_items_repository_impl.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/railway_auth_service.dart';
import '../../usecases/login_user.dart';
import '../../usecases/signup_user.dart';
import '../../usecases/send_password_reset.dart';
import '../../usecases/reset_password.dart';
import '../../usecases/verify_reset_code.dart';
import '../../usecases/verify_email.dart';
import '../../usecases/resend_verification.dart';
import '../../usecases/login_with_google.dart';

/// The HTTP client. Overridden in `main()` with the initialised instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden in main()');
});

// ── Auth ──────────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>(
  (ref) => RailwayAuthService(apiClient: ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(service: ref.read(authServiceProvider)),
);

final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.read(authRepositoryProvider)),
);

final signupUserProvider = Provider<SignupUser>(
  (ref) => SignupUser(ref.read(authRepositoryProvider)),
);

final sendPasswordResetProvider = Provider<SendPasswordReset>(
  (ref) => SendPasswordReset(ref.read(authRepositoryProvider)),
);

final resetPasswordProvider = Provider<ResetPassword>(
  (ref) => ResetPassword(ref.read(authRepositoryProvider)),
);

final verifyResetCodeProvider = Provider<VerifyResetCode>(
  (ref) => VerifyResetCode(ref.read(authRepositoryProvider)),
);

final verifyEmailProvider = Provider<VerifyEmail>(
  (ref) => VerifyEmail(ref.read(authRepositoryProvider)),
);

final resendVerificationProvider = Provider<ResendVerification>(
  (ref) => ResendVerification(ref.read(authRepositoryProvider)),
);

final loginWithGoogleProvider = Provider<LoginWithGoogle>(
  (ref) => LoginWithGoogle(ref.read(authRepositoryProvider)),
);

// ── Profile, saved items, notifications ───────────────────────────────────────
// Posts and chats live in `providers/post_provider.dart` and
// `providers/chat_provider.dart`.

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(apiClient: ref.read(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(apiClient: ref.read(apiClientProvider)),
);

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>(
  (ref) => SavedItemsRepositoryImpl(apiClient: ref.read(apiClientProvider)),
);
