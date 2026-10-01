import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/item_model.dart';
import '../../models/user_model.dart';
import '../../l10n/l10n.dart';

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());

/// The system share sheet (AirDrop, Messages, WhatsApp, ...) for posts and
/// profiles. The post photo is attached when it can be fetched quickly, so
/// the receiver sees the item, the text and the link.
class ShareService {
  /// Where the sheet animates from on iPad; ignored elsewhere.
  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  String postText(ItemModel item) {
    final l10n = L10n.current;
    final kind = item.isResolved
        ? l10n.commonReturned
        : (item.isLost ? l10n.commonLost : l10n.commonFound);
    final lines = <String>[
      l10n.shareKindTitle(kind, item.title),
      if (item.location.trim().isNotEmpty) item.location.trim(),
      if (item.description.trim().isNotEmpty) _excerpt(item.description, 140),
      if (item.shareUrl.isNotEmpty) item.shareUrl,
    ];
    return lines.join('\n');
  }

  /// Opens the share sheet for [item]. Returns true when the sheet opened.
  Future<bool> sharePost(BuildContext context, ItemModel item) async {
    final text = postText(item);
    final origin = _origin(context);
    XFile? photo;
    if (!kIsWeb && item.hasImage && !item.imagePath.startsWith('assets/')) {
      photo = await _cachedPhoto(item.imagePath);
    }
    try {
      final params = ShareParams(
        text: text,
        subject: L10n.current.shareKindTitle(
            item.isLost ? L10n.current.commonLost : L10n.current.commonFound,
            item.title),
        files: photo == null ? null : [photo],
        sharePositionOrigin: origin,
      );
      final result = await SharePlus.instance.share(params);
      return result.status != ShareResultStatus.unavailable;
    } catch (e) {
      debugPrint('Share failed: $e');
      return false;
    }
  }

  Future<bool> shareProfile(BuildContext context, UserModel profile) async {
    final lines = <String>[
      profile.displayName,
      if (profile.nickName.trim().isNotEmpty) '@${profile.nickName.trim()}',
      if (profile.job.trim().isNotEmpty) profile.job.trim(),
      L10n.current.shareFindMe(profile.uid),
    ];
    try {
      await SharePlus.instance.share(ShareParams(
        text: lines.join('\n'),
        subject: L10n.current.shareProfileSubject(profile.displayName),
        sharePositionOrigin: _origin(context),
      ));
      return true;
    } catch (e) {
      debugPrint('Share failed: $e');
      return false;
    }
  }

  /// The post photo from the image cache (the details page has usually
  /// loaded it already), with a short network fallback.
  Future<XFile?> _cachedPhoto(String url) async {
    try {
      final file = await DefaultCacheManager()
          .getSingleFile(url)
          .timeout(const Duration(seconds: 4));
      if (!await file.exists()) return null;
      final ext = file.path.split('.').last.toLowerCase();
      final mime = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
      // Share a copy with a friendly name so the receiver sees "finder-item".
      final copy = File('${file.parent.path}/finder-item.${ext.isEmpty ? 'jpg' : ext}');
      await file.copy(copy.path);
      return XFile(copy.path, mimeType: mime, name: 'finder-item.${ext.isEmpty ? 'jpg' : ext}');
    } catch (e) {
      debugPrint('Share photo unavailable: $e');
      return null;
    }
  }

  static String _excerpt(String s, int n) {
    final t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.length > n ? '${t.substring(0, n - 1).trimRight()}…' : t;
  }
}
