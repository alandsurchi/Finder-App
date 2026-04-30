import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only: native browser file dialog (no plugin needed)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
      return _webPickAndUpload(folder: folder);
    }
    return _mobilePickAndUpload(folder: folder);
  }

  // ── Web: dart:html file input ─────────────────────────────────────────────
  static Future<String?> _webPickAndUpload({required String folder}) {
    final completer = Completer<String?>();
    bool fileSelected = false;

    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..style.display = 'none';

    html.document.body?.append(input);

    // ── File selected ──
    input.onChange.listen((_) async {
      fileSelected = true;
      final file = (input.files?.isNotEmpty == true) ? input.files![0] : null;
      input.remove();

      if (file == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      try {
        // Read bytes from file
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final bytes = Uint8List.fromList(reader.result as List<int>);

        // Upload to Cloudinary
        final url = await _uploadToCloudinary(bytes, folder: folder);
        if (!completer.isCompleted) completer.complete(url);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });

    // ── User cancelled (closed dialog without picking) ──
    // Fallback: resolve with null after 60s if nothing happened
    Future.delayed(const Duration(seconds: 60), () {
      if (!completer.isCompleted && !fileSelected) {
        completer.complete(null);
        input.remove();
      }
    });

    input.click();
    return completer.future;
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
