import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/posts/presentation/item_details_args.dart';
import '../providers/post_provider.dart';
import '../routes.dart';
import 'di/app_providers.dart';
import 'router/root_navigator.dart';

/// Opens posts from links: `https://<api host>/p/<id>` (shared links) and
/// `finder://post/<id>` (the "Open in Finder" button on the share page).
///
/// Links that arrive before sign-in are kept and opened right after.
class DeepLinks {
  DeepLinks(this._ref);

  final Ref _ref;
  final AppLinks _links = AppLinks();
  StreamSubscription<Uri>? _sub;
  Uri? _pending;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      final initial = await _links.getInitialLink();
      if (initial != null) _handle(initial);
      _sub = _links.uriLinkStream.listen(_handle, onError: (Object e) {
        debugPrint('Deep link error: $e');
      });
    } catch (e) {
      debugPrint('Deep links unavailable: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  /// Opens a link that arrived while the user was signed out.
  Future<void> flushPending() async {
    final uri = _pending;
    if (uri == null) return;
    _pending = null;
    await _open(uri);
  }

  /// The post id a link points at, or null for anything else.
  static String? postIdOf(Uri uri) {
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (uri.scheme == 'finder') {
      // finder://post/<id>  (host = "post")
      if (uri.host == 'post' && segs.isNotEmpty) return segs.first;
      return null;
    }
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        segs.length >= 2 &&
        segs.first == 'p') {
      return segs[1];
    }
    return null;
  }

  void _handle(Uri uri) {
    final api = _ref.read(apiClientProvider);
    if (!api.isAuthenticated || rootNavigatorKey.currentState == null) {
      _pending = uri;
      return;
    }
    _open(uri);
  }

  Future<void> _open(Uri uri) async {
    final id = postIdOf(uri);
    final nav = rootNavigatorKey.currentState;
    if (id == null || nav == null) return;
    try {
      final item = await _ref.read(postServiceProvider).fetchById(id);
      nav.pushNamed(AppRoutes.itemDetails, arguments: ItemDetailsArgs(item));
    } catch (e) {
      debugPrint('Could not open shared post $id: $e');
    }
  }
}

final deepLinksProvider = Provider<DeepLinks>((ref) {
  final links = DeepLinks(ref);
  ref.onDispose(links.dispose);
  return links;
});
