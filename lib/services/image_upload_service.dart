import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only: native browser file dialog (no plugin needed). The dart:html
// implementation is only linked on web; other platforms get a stub.
import 'upload/web_picker_stub.dart'
    if (dart.library.html) 'upload/web_picker_web.dart' as web_picker;

// Mobile-only: image_picker
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  CLOUDINARY CONFIG (free plan — no credit card required)
// ─────────────────────────────────────────────────────────────────────────────
const _kCloudName    = 'djohuzvho';
const _kUploadPreset = 'finder_unsigned';

class ImageUploadService {
  /// Picks an image from the device/browser and uploads it to Cloudinary.
  /// Returns the public download URL, or null if the user cancelled.
  static Future<String?> pickAndUpload({
    required String folder,
    required String fileName,
  }) {
    if (kIsWeb) {
      return web_picker.webPickAndUpload(
        folder: folder,
        upload: _uploadToCloudinary,
      );
    }
    return _mobilePickAndUpload(folder: folder);
  }

  // ── Mobile: image_picker ────────────────────────────────────────────────
  static Future<String?> _mobilePickAndUpload({required String folder}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return _uploadToCloudinary(bytes, folder: folder);
  }

  // ── Cloudinary REST upload (multipart/form-data) ─────────────────────────
  static Future<String> _uploadToCloudinary(
    Uint8List bytes, {
    required String folder,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_kCloudName/image/upload',
    );

    // Use multipart upload — much more reliable than base64 form field
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _kUploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'image.jpg',
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
        'Upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary returned no URL. Response: ${response.body}');
    }
    return url;
  }
}
