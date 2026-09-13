// Non-web platforms never call the browser picker; this stub keeps the
// conditional import satisfied without pulling in dart:html.
import 'dart:typed_data';

Future<String?> webPickAndUpload({
  required String folder,
  required Future<String> Function(Uint8List bytes, {required String folder}) upload,
}) async {
  throw UnsupportedError('Browser file picker is only available on web.');
}
