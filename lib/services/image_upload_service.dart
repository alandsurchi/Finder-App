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
import '../core/utils/image_mime.dart';

/// Where a picked image comes from.
enum ImageSourceKind { gallery, camera }

/// A file stored privately on the server plus the bytes for a local preview.
class PrivateUpload {
  final String fileId;
  final Uint8List bytes;
  const PrivateUpload({required this.fileId, required this.bytes});
}

/// Picks an image and uploads it to the Finder backend (`POST /uploads`),
/// which stores it on its own volume and returns the public URL.
class ImageUploadService {
  final ApiClient _apiClient;

  ImageUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const int maxBytes = 8 * 1024 * 1024;

  /// Returns the public URL, or null when the user cancelled the picker.
  ///
  /// On the web the browser's file dialog is used for both sources.
  Future<String?> pickAndUpload({
    required String folder,
    required String fileName,
    ImageSourceKind source = ImageSourceKind.gallery,
  }) {
    if (kIsWeb) {
      return web_picker.webPickAndUpload(folder: folder, upload: _upload);
    }
    return _mobilePickAndUpload(folder: folder, source: source);
  }

  Future<String?> _mobilePickAndUpload({
    required String folder,
    required ImageSourceKind source,
  }) async {
    final bytes = await _pickBytes(source: source);
    if (bytes == null) return null;
    return _upload(bytes, folder: folder);
  }

  /// Identity documents and selfies: stored privately, never public.
  /// Returns null when the picker was cancelled.
  Future<PrivateUpload?> pickAndUploadPrivate({
    required String slot,
    required ImageSourceKind source,
    bool frontCamera = false,
  }) async {
    Uint8List? bytes;
    if (kIsWeb) {
      String? id;
      final r = await web_picker.webPickAndUpload(
        folder: slot,
        upload: (b, {required String folder}) async {
          bytes = b;
          id = await _uploadPrivate(b, slot: slot);
          return id!;
        },
      );
      if (r == null || bytes == null) return null;
      return PrivateUpload(fileId: r, bytes: bytes!);
    }
    bytes = await _pickBytes(source: source, frontCamera: frontCamera);
    if (bytes == null) return null;
    final id = await _uploadPrivate(bytes!, slot: slot);
    return PrivateUpload(fileId: id, bytes: bytes!);
  }

  Future<Uint8List?> _pickBytes({
    required ImageSourceKind source,
    bool frontCamera = false,
  }) async {
    final picker = ImagePicker();
    final XFile? picked;
    try {
      picked = await picker.pickImage(
        source: source == ImageSourceKind.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        preferredCameraDevice:
            frontCamera ? CameraDevice.front : CameraDevice.rear,
        // Re-encodes large photos (including HEIC on most devices) to a
        // JPEG the whole app can display, and keeps uploads small.
        imageQuality: 82,
        maxWidth: 1800,
        maxHeight: 1800,
        requestFullMetadata: false,
      );
    } catch (e) {
      throw ValidationException(_describePickerError(e, source));
    }
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  Future<String> _uploadPrivate(Uint8List bytes, {required String slot}) async {
    if (bytes.isEmpty) {
      throw const ValidationException('The selected file is empty.');
    }
    if (bytes.lengthInBytes > maxBytes) {
      throw const ValidationException('Please choose an image under 8 MB.');
    }
    final kind = sniffImage(bytes);
    final res = await _apiClient.uploadFile(
      '/profile/verification/upload',
      bytes: bytes,
      filename: 'image.${kind?.extension ?? 'bin'}',
      contentType: kind?.mime ?? 'application/octet-stream',
      fields: {'slot': slot},
    );
    final id = (res as Map)['fileId']?.toString();
    if (id == null || id.isEmpty) {
      throw const UnknownException('The server returned no file id.');
    }
    return id;
  }

  Future<String> _upload(Uint8List bytes, {required String folder}) async {
    if (bytes.isEmpty) {
      throw const ValidationException('The selected file is empty.');
    }
    if (bytes.lengthInBytes > maxBytes) {
      throw const ValidationException('Please choose an image under 8 MB.');
    }
    // Label the upload from its bytes; the picker's own type is unreliable.
    final kind = sniffImage(bytes);
    final res = await _apiClient.uploadFile(
      '/uploads',
      bytes: bytes,
      filename: 'image.${kind?.extension ?? 'bin'}',
      contentType: kind?.mime ?? 'application/octet-stream',
      fields: {'folder': folder},
    );
    final url = (res as Map)['url']?.toString();
    if (url == null || url.isEmpty) {
      throw const UnknownException('The server returned no image URL.');
    }
    return url;
  }

  String _describePickerError(Object e, ImageSourceKind source) {
    final text = e.toString().toLowerCase();
    if (text.contains('camera_access_denied') || text.contains('camera')) {
      return 'Camera access was denied. Allow it in your phone settings or choose a photo from the gallery.';
    }
    if (text.contains('photo_access_denied') || text.contains('permission')) {
      return 'Photo access was denied. Allow it in your phone settings and try again.';
    }
    return source == ImageSourceKind.camera
        ? 'Could not open the camera.'
        : 'Could not open the photo picker.';
  }
}
