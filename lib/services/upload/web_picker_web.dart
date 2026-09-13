// Web implementation of the browser file picker (dart:html).
// Selected via conditional import from image_upload_service.dart.
import 'dart:async';
import 'dart:typed_data';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// ── Web: dart:html file input ─────────────────────────────────────────────
Future<String?> webPickAndUpload({
required String folder,
required Future<String> Function(Uint8List bytes, {required String folder}) upload,
}) {
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
      final url = await upload(bytes, folder: folder);
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
