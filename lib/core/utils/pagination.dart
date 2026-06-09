import '../constants/api_constants.dart';

class PageRequest {
  final int limit;
  final String? cursor;

  const PageRequest({this.limit = ApiConstants.defaultPageSize, this.cursor});
}

class PageResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const PageResult({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}
