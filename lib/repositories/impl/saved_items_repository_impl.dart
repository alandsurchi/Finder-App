import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../models/item_model.dart';
import '../saved_items_repository.dart';

class SavedItemsRepositoryImpl implements SavedItemsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const SavedItemsRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Result<List<ItemModel>>> getSavedItems() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.success(const []);
    }

    try {
      final snapshot = await _savedItems(
        user.uid,
      ).orderBy('updatedAtMs', descending: true).get();

      final items = snapshot.docs.map(_toItem).toList(growable: false);
      return Result.success(items);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load saved items right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateSavedItems(List<ItemModel> items) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to save items.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final collection = _savedItems(user.uid);
      final existingSnapshot = await collection.get();
      final batch = _firestore.batch();

      final targetIds = items
          .map((item) => item.id.trim())
          .where((id) => id.isNotEmpty)
          .toSet();

      for (final doc in existingSnapshot.docs) {
        if (!targetIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }

      for (final item in items) {
        final id = item.id.trim().isEmpty
            ? collection.doc().id
            : item.id.trim();
        batch.set(
          collection.doc(id),
          _toMap(item, id),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update saved items right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _savedItems(String userId) {
    return _firestore.collection('users').doc(userId).collection('savedItems');
  }

  ItemModel _toItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ItemModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      timeAgo: _relativeTime(_asInt(data['createdAtMs'])),
      imagePath: data['imagePath']?.toString() ?? '',
      isLost: data['isLost'] as bool? ?? true,
      reward: data['reward']?.toString(),
      isVerified: data['isVerified'] as bool? ?? false,
      category: data['category']?.toString() ?? 'Other',
      lostOn: data['lostOn']?.toString(),
      lastSeenAt: data['lastSeenAt']?.toString(),
      ownerName: data['ownerName']?.toString(),
      ownerTrustScore: _asDouble(data['ownerTrustScore']),
    );
  }

  Map<String, dynamic> _toMap(ItemModel item, String id) {
    return {
      'id': id,
      'title': item.title,
      'description': item.description,
      'location': item.location,
      'imagePath': item.imagePath,
      'isLost': item.isLost,
      'reward': item.reward,
      'isVerified': item.isVerified,
      'category': item.category,
      'lostOn': item.lostOn,
      'lastSeenAt': item.lastSeenAt,
      'ownerName': item.ownerName,
      'ownerTrustScore': item.ownerTrustScore,
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  String _relativeTime(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) {
      return 'Just now';
    }

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
