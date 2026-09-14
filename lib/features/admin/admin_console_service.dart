import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/app_providers.dart';
import '../../core/network/api_client.dart';
import '../../models/item_model.dart';

/// Overview numbers for the console home.
class AdminStats {
  final int users, bannedUsers, verifiedUsers;
  final int posts, openPosts, returnedPosts;
  final int pendingReports, pendingVerifications, messagesToday;

  const AdminStats({
    required this.users,
    required this.bannedUsers,
    required this.verifiedUsers,
    required this.posts,
    required this.openPosts,
    required this.returnedPosts,
    required this.pendingReports,
    required this.pendingVerifications,
    required this.messagesToday,
  });

  factory AdminStats.fromApi(Map<String, dynamic> m) {
    int n(String k) => (m[k] as num?)?.toInt() ?? 0;
    return AdminStats(
      users: n('users'),
      bannedUsers: n('bannedUsers'),
      verifiedUsers: n('verifiedUsers'),
      posts: n('posts'),
      openPosts: n('openPosts'),
      returnedPosts: n('returnedPosts'),
      pendingReports: n('pendingReports'),
      pendingVerifications: n('pendingVerifications'),
      messagesToday: n('messagesToday'),
    );
  }
}

/// A user as the console sees them.
class AdminUser {
  final String uid, name, email, avatarUrl, authProvider;
  final bool identityVerified, isAdmin, isBanned;
  final int postsCount, reportsAgainst, createdAtMs;

  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.authProvider,
    required this.identityVerified,
    required this.isAdmin,
    required this.isBanned,
    required this.postsCount,
    required this.reportsAgainst,
    required this.createdAtMs,
  });

  factory AdminUser.fromApi(Map<String, dynamic> m) => AdminUser(
        uid: m['uid']?.toString() ?? '',
        name: m['name']?.toString() ?? 'Finder User',
        email: m['email']?.toString() ?? '',
        avatarUrl: m['avatarUrl']?.toString() ?? '',
        authProvider: m['authProvider']?.toString() ?? 'email',
        identityVerified: m['identityVerified'] == true,
        isAdmin: m['isAdmin'] == true,
        isBanned: m['isBanned'] == true,
        postsCount: (m['postsCount'] as num?)?.toInt() ?? 0,
        reportsAgainst: (m['reportsAgainst'] as num?)?.toInt() ?? 0,
        createdAtMs: (m['createdAtMs'] as num?)?.toInt() ?? 0,
      );
}

/// A report on a post.
class AdminReport {
  final String id, postId, postTitle, postStatus, postOwnerId, postOwnerName;
  final String reporterId, reporterName, reporterEmail, reason, status;
  final int createdAtMs;
  final int? reviewedAtMs;
  final String? resolution;

  const AdminReport({
    required this.id,
    required this.postId,
    required this.postTitle,
    required this.postStatus,
    required this.postOwnerId,
    required this.postOwnerName,
    required this.reporterId,
    required this.reporterName,
    required this.reporterEmail,
    required this.reason,
    required this.status,
    required this.createdAtMs,
    this.reviewedAtMs,
    this.resolution,
  });

  bool get isPending => status == 'pending';

  factory AdminReport.fromApi(Map<String, dynamic> m) => AdminReport(
        id: m['id']?.toString() ?? '',
        postId: m['postId']?.toString() ?? '',
        postTitle: m['postTitle']?.toString() ?? '',
        postStatus: m['postStatus']?.toString() ?? '',
        postOwnerId: m['postOwnerId']?.toString() ?? '',
        postOwnerName: m['postOwnerName']?.toString() ?? '',
        reporterId: m['reporterId']?.toString() ?? '',
        reporterName: m['reporterName']?.toString() ?? 'Finder User',
        reporterEmail: m['reporterEmail']?.toString() ?? '',
        reason: m['reason']?.toString() ?? '',
        status: m['status']?.toString() ?? 'pending',
        createdAtMs: (m['createdAtMs'] as num?)?.toInt() ?? 0,
        reviewedAtMs: (m['reviewedAtMs'] as num?)?.toInt(),
        resolution: m['resolution']?.toString(),
      );
}

/// Console calls. The server answers 403 for non-admin accounts.
class AdminConsoleService {
  final ApiClient _api;
  AdminConsoleService({required ApiClient apiClient}) : _api = apiClient;

  List<Map<String, dynamic>> _list(dynamic res) =>
      res is List ? res.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : const [];

  Future<AdminStats> stats() async =>
      AdminStats.fromApi(Map<String, dynamic>.from(await _api.get('/admin/stats') as Map));

  Future<List<AdminUser>> users({String query = '', String filter = 'all'}) async {
    final q = Uri.encodeQueryComponent(query.trim());
    return _list(await _api.get('/admin/users?q=$q&filter=$filter'))
        .map(AdminUser.fromApi)
        .toList();
  }

  Future<void> setBanned(String uid, bool value) =>
      _api.post('/admin/users/$uid/ban', {'value': value});
  Future<void> setVerified(String uid, bool value) =>
      _api.post('/admin/users/$uid/verify', {'value': value});
  Future<void> setAdmin(String uid, bool value) =>
      _api.post('/admin/users/$uid/admin', {'value': value});
  Future<void> deleteUser(String uid) => _api.delete('/admin/users/$uid');

  Future<List<ItemModel>> posts({String query = '', String status = 'all'}) async {
    final q = Uri.encodeQueryComponent(query.trim());
    return _list(await _api.get('/admin/posts?q=$q&status=$status'))
        .map(ItemModel.fromApi)
        .toList();
  }

  Future<void> setPostStatus(String id, String status) =>
      _api.post('/admin/posts/$id/status', {'status': status});
  Future<void> deletePost(String id, {String reason = ''}) =>
      _api.deleteWithBody('/admin/posts/$id', {'reason': reason});

  Future<List<AdminReport>> reports({String status = 'pending'}) async =>
      _list(await _api.get('/admin/reports?status=$status'))
          .map(AdminReport.fromApi)
          .toList();

  Future<void> resolveReport(String id, {required bool removePost}) =>
      _api.post('/admin/reports/$id/resolve',
          {'action': removePost ? 'remove_post' : 'dismiss'});
}

final adminConsoleServiceProvider = Provider<AdminConsoleService>(
  (ref) => AdminConsoleService(apiClient: ref.read(apiClientProvider)),
);

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => ref.read(adminConsoleServiceProvider).stats(),
);

/// Key: "filter|query".
final adminUsersProvider =
    FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, key) {
  final i = key.indexOf('|');
  final filter = i < 0 ? key : key.substring(0, i);
  final query = i < 0 ? '' : key.substring(i + 1);
  return ref.read(adminConsoleServiceProvider).users(query: query, filter: filter);
});

/// Key: "status|query".
final adminPostsProvider =
    FutureProvider.autoDispose.family<List<ItemModel>, String>((ref, key) {
  final i = key.indexOf('|');
  final status = i < 0 ? key : key.substring(0, i);
  final query = i < 0 ? '' : key.substring(i + 1);
  return ref.read(adminConsoleServiceProvider).posts(query: query, status: status);
});

final adminReportsProvider =
    FutureProvider.autoDispose.family<List<AdminReport>, String>((ref, status) {
  return ref.read(adminConsoleServiceProvider).reports(status: status);
});
