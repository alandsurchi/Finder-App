import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../services/notification_service.dart';

class MyPostsNotifier extends StateNotifier<AsyncValue<List<ItemModel>>> {
  MyPostsNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      // Simple single-field filter — no composite index required
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      final items = snap.docs
          .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(items);
    } on FirebaseException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .delete();
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.where((p) => p.id != postId).toList(),
      );
    } catch (_) {}
  }

  Future<void> markResolved(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({
        'isResolved': true,
        'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
      });

      final current = state.value ?? [];

      // Notify the owner (themselves) that their post was resolved
      final resolvedPost = current.where((p) => p.id == postId).isNotEmpty
          ? current.firstWhere((p) => p.id == postId)
          : null;
      if (resolvedPost != null) {
        await NotificationService.notifyResolved(postTitle: resolvedPost.title);
      }

      state = AsyncValue.data(current.map((p) {
        if (p.id == postId) {
          return ItemModel(
            id: p.id,
            ownerId: p.ownerId,
            title: p.title,
            description: p.description,
            createdAt: p.createdAt,
            location: p.location,
            timeAgo: p.timeAgo,
            imagePath: p.imagePath,
            isLost: p.isLost,
            reward: p.reward,
            isVerified: p.isVerified,
            category: p.category,
            lostOn: p.lostOn,
            lastSeenAt: p.lastSeenAt,
            ownerName: p.ownerName,
            ownerTrustScore: p.ownerTrustScore,
            isResolved: true,
          );
        }
        return p;
      }).toList());
    } catch (_) {}
  }

  Future<void> updatePost(ItemModel updated) async {
    try {
      final data = updated.toMap()
        ..['updatedAtMs'] = DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(updated.id)
          .update(data);

      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((p) => p.id == updated.id ? updated : p).toList(),
      );
    } catch (_) {}
  }
}

final myPostsProvider =
    StateNotifierProvider<MyPostsNotifier, AsyncValue<List<ItemModel>>>(
  (ref) => MyPostsNotifier(),
);
