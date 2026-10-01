import 'package:flutter/material.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/services/image_upload_service.dart' show ImageSourceKind;
import 'package:finder/widgets/ui/ui.dart';

/// Lets the user choose between the camera and the photo library.
/// Resolves with null when dismissed.
Future<ImageSourceKind?> showImageSourceSheet(
  BuildContext context, {
  String? title,
  String? subtitle,
}) {
  final l10n = context.l10n;
  return AppBottomSheet.show<ImageSourceKind>(
    context,
    builder: (sheetCtx) => AppBottomSheet(
      title: title ?? l10n.photoAddTitle,
      subtitle: subtitle,
      scrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetOption(
            icon: Icons.photo_camera_outlined,
            label: l10n.photoTakePhoto,
            subtitle: l10n.photoOpenCamera,
            onTap: () => Navigator.pop(sheetCtx, ImageSourceKind.camera),
          ),
          SheetOption(
            icon: Icons.photo_library_outlined,
            label: l10n.photoChooseGallery,
            subtitle: l10n.photoPickExisting,
            onTap: () => Navigator.pop(sheetCtx, ImageSourceKind.gallery),
          ),
          const SizedBox(height: BeaconSpace.lg),
        ],
      ),
    ),
  );
}
