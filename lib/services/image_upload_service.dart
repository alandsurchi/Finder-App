import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only: native browser file dialog (no plugin needed). The dart:html
// implementation is only linked on web; other platforms get a stub.
import 'upload/web_picker_stub.dart'
    if (dart.library.html) 'upload/web_picker_web.dart' as web_picker;

// Mobile-only: image_picker
import 'package:image_picker/image_picker.dart';

import '../core/errors/exceptions.dart';
import '../core/network/api_client.dart';

/// Picks an image and uploads it to the Finder backend (`POST /uploads`),
/// which stores it on its own volume and returns the public URL.
class ImageUploadService {
  final ApiClient _apiClient;

  ImageUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const int maxBytes = 8 * 1024 * 1024;

  /// Returns the public URL, or null when the user cancelled the picker.
  Future<String?> pickAndUpload({
    required String folder,
    required String fileName,
  }) {
    if (kIsWeb) {
      return web_picker.webPickAndUpload(folder: folder, upload: _upload);
    }
    return _mobilePickAndUpload(folder: folder);
  }

  Future<String?> _mobilePickAndUpload({required String folder}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return _upload(bytes, folder: folder);
  }

  Future<String> _upload(Uint8List bytes, {required String folder}) async {
    if (bytes.lengthInBytes > maxBytes) {
      throw const ValidationException('Please choose an image under 8 MB.');
    }
    final res = await _apiClient.uploadFile(
      '/uploads',
      bytes: bytes,
      filename: 'image.jpg',
      fields: {'folder': folder},
    );
    final url = (res as Map)['url']?.toString();
    if (url == null || url.isEmpty) {
      throw const UnknownException('The server returned no image URL.');
    }
    return url;
  }
}
