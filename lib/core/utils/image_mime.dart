import 'dart:typed_data';

/// The detected format of an image file.
class ImageKind {
  final String mime;
  final String extension;
  const ImageKind(this.mime, this.extension);
}

/// Detects the image format from the first bytes of a file.
///
/// Pickers on different platforms report unreliable MIME types (or none at
/// all), so uploads are labelled from the bytes instead. Returns null for
/// anything that is not a recognised raster image.
ImageKind? sniffImage(Uint8List b) {
  if (b.length < 12) return null;
  String ascii(int from, int to) => String.fromCharCodes(b.sublist(from, to));

  if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
    return const ImageKind('image/jpeg', 'jpg');
  }
  if (b[0] == 0x89 && ascii(1, 4) == 'PNG') {
    return const ImageKind('image/png', 'png');
  }
  if (ascii(0, 6) == 'GIF87a' || ascii(0, 6) == 'GIF89a') {
    return const ImageKind('image/gif', 'gif');
  }
  if (ascii(0, 4) == 'RIFF' && ascii(8, 12) == 'WEBP') {
    return const ImageKind('image/webp', 'webp');
  }
  if (b[0] == 0x42 && b[1] == 0x4D) {
    return const ImageKind('image/bmp', 'bmp');
  }
  if ((b[0] == 0x49 && b[1] == 0x49 && b[2] == 0x2A && b[3] == 0x00) ||
      (b[0] == 0x4D && b[1] == 0x4D && b[2] == 0x00 && b[3] == 0x2A)) {
    return const ImageKind('image/tiff', 'tif');
  }
  if (ascii(4, 8) == 'ftyp') {
    final brand = ascii(8, 12);
    if (RegExp(r'^(heic|heix|hevc|hevx|mif1|msf1)').hasMatch(brand)) {
      return const ImageKind('image/heic', 'heic');
    }
    if (RegExp(r'^avi[fs]').hasMatch(brand)) {
      return const ImageKind('image/avif', 'avif');
    }
  }
  return null;
}
