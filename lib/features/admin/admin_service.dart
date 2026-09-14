import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/app_providers.dart';
import '../../core/network/api_client.dart';

/// One identity-verification request as the admin queue sees it.
class AdminVerificationRequest {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String avatarUrl;
  final String docType;
  final String status;
  final bool hasBack;
  final int createdAtMs;
  final int? reviewedAtMs;
  final String? rejectionReason;

  const AdminVerificationRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.avatarUrl,
    required this.docType,
    required this.status,
    required this.hasBack,
    required this.createdAtMs,
    this.reviewedAtMs,
    this.rejectionReason,
  });

  bool get isPending => status == 'pending';

  factory AdminVerificationRequest.fromApi(Map<String, dynamic> m) {
    return AdminVerificationRequest(
      id: m['id']?.toString() ?? '',
      userId: m['userId']?.toString() ?? '',
      userName: m['userName']?.toString() ?? 'Finder User',
      email: m['email']?.toString() ?? '',
      avatarUrl: m['avatarUrl']?.toString() ?? '',
      docType: m['docType']?.toString() ?? '',
      status: m['status']?.toString() ?? 'pending',
      hasBack: m['hasBack'] == true,
      createdAtMs: (m['createdAtMs'] as num?)?.toInt() ?? 0,
      reviewedAtMs: (m['reviewedAtMs'] as num?)?.toInt(),
      rejectionReason: m['rejectionReason']?.toString(),
    );
  }

  /// API path of one of the stored images (needs the session token).
  String filePath(String slot) => '/admin/verification/$id/file/$slot';

  String get docLabel => switch (docType) {
        'id_card' => 'Identity card',
        'drivers_license' => "Driver's license",
        'passport' => 'Passport',
        _ => 'Document',
      };
}

/// Admin-only calls. The server refuses them (403) for normal accounts.
class AdminService {
  final ApiClient _api;
  AdminService({required ApiClient apiClient}) : _api = apiClient;

  Future<List<AdminVerificationRequest>> listVerification(String status) async {
    final res = await _api.get('/admin/verification?status=$status');
    if (res is! List) return const [];
    return res
        .whereType<Map>()
        .map((m) => AdminVerificationRequest.fromApi(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> approve(String id) =>
      _api.post('/admin/verification/$id/approve', const {});

  Future<void> reject(String id, String reason) =>
      _api.post('/admin/verification/$id/reject', {'reason': reason});
}

final adminServiceProvider = Provider<AdminService>(
  (ref) => AdminService(apiClient: ref.read(apiClientProvider)),
);

/// The review queue for one status: pending | approved | rejected.
final adminVerificationQueueProvider = FutureProvider.autoDispose
    .family<List<AdminVerificationRequest>, String>((ref, status) {
  return ref.read(adminServiceProvider).listVerification(status);
});
