import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// Web-only: native browser file dialog (no plugin needed). The dart:html
// implementation is only linked on web; other platforms get a stub.
import 'upload/web_picker_stub.dart'
    if (dart.library.html) 'upload/web_picker_web.dart' as web_picker;

// Mobile-only: image_picker
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

import '../core/errors/exceptions.dart';
import '../core/network/api_client.dart';

// Unsigned preset, used only by debug builds when the backend has no
// Cloudinary credentials. Release builds always upload with a signature.
const _kDevCloudName = 'djohuzvho';
const _kDevUploadPreset = 'finder_unsigned';

/// Picks an image and uploads it to Cloudinary.
///
/// The backend signs every upload (`POST /uploads/sign`), so the API secret
/// never ships in the app and uploads are limited to signed-in users and to
/// the folders the server allows.
class ImageUploadService {
  final ApiClient _apiClient;
  final http.Client _http;

  ImageUploadService({required ApiClient apiClient, http.Client? httpClient})
      : _apiClient = apiClient,
        _http = httpClient ?? http.Client();

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

  static const int maxBytes = 8 * 1024 * 1024;

  Future<String> _upload(Uint8List bytes, {required String folder}) async {
    if (bytes.lengthInBytes > maxBytes) {
      throw const ValidationException('Please choose an image under 8 MB.');
    }

    final request = await _signedRequest(folder);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'image.jpg'));

    final streamed = await _http.send(request).timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw UnknownException(_cloudinaryError(response));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw const UnknownException('The image service returned no URL.');
    }
    return url;
  }

  /// Asks the backend for a signature. Falls back to the unsigned dev preset
  /// only in debug builds when the server has no Cloudinary credentials.
  Future<http.MultipartRequest> _signedRequest(String folder) async {
    try {
      final res = await _apiClient.post('/uploads/sign', {'folder': folder});
      final map = Map<String, dynamic>.from(res as Map);
      final request = http.MultipartRequest('POST', Uri.parse(map['uploadUrl'] as String))
        ..fields['api_key'] = map['apiKey'].toString()
        ..fields['timestamp'] = map['timestamp'].toString()
        ..fields['signature'] = map['signature'].toString()
        ..fields['folder'] = map['folder'].toString();
      return request;
    } on ApiException catch (e) {
      if (e.statusCode == 503 && kDebugMode) {
        return http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/$_kDevCloudName/image/upload'),
        )
          ..fields['upload_preset'] = _kDevUploadPreset
          ..fields['folder'] = folder;
      }
      rethrow;
    }
  }

  static String _cloudinaryError(http.Response response) {
    try {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (map['error'] as Map?)?['message']?.toString();
      if (message != null && message.isNotEmpty) return 'Upload failed: $message';
    } catch (_) {}
    return 'Upload failed (${response.statusCode}).';
  }
}
