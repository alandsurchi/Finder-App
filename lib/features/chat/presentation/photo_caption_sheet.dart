import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/ui/ui.dart';

/// Preview of the picked photo with an optional caption, like WhatsApp.
/// Resolves with the caption (possibly empty) or null when dismissed.
Future<String?> showPhotoCaptionSheet(BuildContext context, Uint8List bytes) {
  return AppBottomSheet.show<String>(
    context,
    builder: (sheetCtx) => _PhotoCaptionSheet(bytes: bytes),
  );
}

class _PhotoCaptionSheet extends StatefulWidget {
  final Uint8List bytes;
  const _PhotoCaptionSheet({required this.bytes});

  @override
  State<_PhotoCaptionSheet> createState() => _PhotoCaptionSheetState();
}

class _PhotoCaptionSheetState extends State<_PhotoCaptionSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height;
    return AppBottomSheet(
      title: l10n.chatSendPhoto,
      actions: [
        AppButton.ghost(label: l10n.commonCancel, onPressed: () => Navigator.pop(context)),
        AppButton(
          label: l10n.commonSend,
          icon: Icons.send_rounded,
          iconTrailing: true,
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BeaconRadius.rLg,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.45),
              child: Image.memory(widget.bytes, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: BeaconSpace.md),
          AppTextField(
            controller: _ctrl,
            hint: l10n.chatAddCaption,
            maxLines: 3,
            minLines: 1,
            maxLength: 500,
            autofocus: true,
          ),
        ],
      ),
    );
  }
}
