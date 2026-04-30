import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/pagination.dart';
import '../../models/dto/post_dto.dart';
import 'post_service.dart';

class FirebasePostService implements PostService {
  final FirebaseFirestore _firestore;

  const FirebasePostService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  @override
  Future<PageResult<PostDto>> fetchPosts(PageRequest request) async {
    try {
      final limit = _normalizedLimit(request.limit);
      Query<Map<String, dynamic>> query = _posts;

      final cursorMs = request.cursor == null
          ? null
          : int.tryParse(request.cursor!.trim());
      if (cursorMs != null) {
        query = query.where('createdAtMs', isLessThan: cursorMs);
      }

      final snapshot = await query
          .orderBy('createdAtMs', descending: true)
          .limit(limit)
          .get();

      final docs = snapshot.docs;
      final items = docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return PostDto.fromMap(data);
          })
          .toList(growable: false);

      final hasMore = docs.length == limit;
      final nextCursor = hasMore && docs.isNotEmpty
          ? _asInt(docs.last.data()['createdAtMs'])?.toString()
          : null;

      return PageResult(items: items, nextCursor: nextCursor, hasMore: hasMore);
    } on FirebaseException catch (e) {
      throw NetworkException('Unable to load posts right now.', code: e.code);
    }
  }

  @override
  Future<PostDto> createPost(PostDto dto) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final createdAtMs = dto.createdAtMs ?? now;
      final id = dto.id.isEmpty ? _posts.doc().id : dto.id;

      final payload = dto.toMap()
        ..['id'] = id
        ..['createdAtMs'] = createdAtMs
        ..['updatedAtMs'] = now
        ..['status'] = dto.status.isEmpty ? 'active' : dto.status;

      await _posts.doc(id).set(payload, SetOptions(merge: true));

      final createdSnapshot = await _posts.doc(id).get();
      final createdMap = Map<String, dynamic>.from(
        createdSnapshot.data() ?? payload,
      )..['id'] = id;

      return PostDto.fromMap(createdMap);
    } on FirebaseException catch (e) {
      throw NetworkException('Unable to create post right now.', code: e.code);
    }
  }

  int _normalizedLimit(int limit) {
    if (limit <= 0) return ApiConstants.defaultPageSize;
    if (limit > ApiConstants.maxPageSize) return ApiConstants.maxPageSize;
    return limit;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
