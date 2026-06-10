import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/user_model.dart';
import '../app/di/app_providers.dart';
import '../core/utils/timestamp.dart';

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  
  try {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/profile/$userId');
    if (res == null) return null;
    
    final map = Map<String, dynamic>.from(res);
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      nickName: map['nickName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      job: map['job']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
});
