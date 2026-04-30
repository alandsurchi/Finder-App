import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time stream of all posts
  Stream<List<ItemModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create a new post
  Future<void> createPost(ItemModel post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toMap());
  }

  // Update a post
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _firestore.collection('posts').doc(id).update(data);
  }

  // Delete a post
  Future<void> deletePost(String id) async {
    await _firestore.collection('posts').doc(id).delete();
  }

  // Mark post as resolved
  Future<void> markAsResolved(String id) async {
    await _firestore.collection('posts').doc(id).update({'isResolved': true});
  }

  // Report post
  Future<void> reportPost(String postId, String reporterId, String reason) async {
    await _firestore.collection('reports').add({
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
