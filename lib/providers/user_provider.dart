import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finder/models/user_model.dart';

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
});
