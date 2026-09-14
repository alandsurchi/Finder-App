import 'package:flutter/material.dart';
import 'package:finder/services/image_upload_service.dart' show ImageSourceKind;
import 'package:finder/widgets/ui/ui.dart';

/// Lets the user choose between the camera and the photo library.
/// Resolves with null when dismissed.
Future<ImageSourceKind?> showImageSourceSheet(
  BuildContext context, {
  String title = 'Add a photo',
  String? subtitle,
}) {
  return AppBottomSheet.show<ImageSourceKind>(
    context,
    builder: (sheetCtx) => AppBottomSheet(
      title: title,
      subtitle: subtitle,
      scrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetOption(
            icon: Icons.photo_camera_outlined,
            label: 'Take a photo',
            subtitle: 'Open the camera',
            onTap: () => Navigator.pop(sheetCtx, ImageSourceKind.camera),
          ),
          SheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            subtitle: 'Pick an existing picture',
            onTap: () => Navigator.pop(sheetCtx, ImageSourceKind.gallery),
          ),
          const SizedBox(height: BeaconSpace.lg),
        ],
      ),
    ),
  );
}
