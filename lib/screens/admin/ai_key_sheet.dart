import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Lets an admin install the Google AI Studio key on the server from the
/// phone (the hosting dashboard is not always reachable). Shows whether a
/// key is configured; never shows the key itself.
Future<void> showAiKeySheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  final service = ref.read(adminConsoleServiceProvider);
  return AppBottomSheet.show<void>(
    context,
    builder: (sheetCtx) => _AiKeySheet(l10n: l10n, service: service),
  );
}

class _AiKeySheet extends StatefulWidget {
  final AppLocalizations l10n;
  final AdminConsoleService service;
  const _AiKeySheet({required this.l10n, required this.service});

  @override
  State<_AiKeySheet> createState() => _AiKeySheetState();
}

class _AiKeySheetState extends State<_AiKeySheet> {
  final _ctrl = TextEditingController();
  AiKeyInfo? _info;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.service.aiKeyInfo().then((i) {
      if (mounted) setState(() { _info = i; _loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _ctrl.text.trim();
    if (key.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final info = await widget.service.setAiKey(key);
      if (!mounted) return;
      setState(() { _info = info; _saving = false; });
      _ctrl.clear();
      ActionFeedback.showSuccess(context, widget.l10n.adminAiKeySaved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ActionFeedback.showError(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final info = _info;
    final configured = info?.configured == true;
    return AppBottomSheet(
      title: l10n.adminAiTitle,
      subtitle: l10n.adminAiSubtitle,
      actions: [
        AppButton.ghost(label: l10n.commonClose, onPressed: () => Navigator.pop(context)),
        AppButton(
          label: l10n.commonSave,
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                configured ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: configured ? t.found : t.accentDeep,
                size: 20,
              ),
              const SizedBox(width: BeaconSpace.sm),
              Expanded(
                child: Text(
                  _loading
                      ? l10n.commonLoading
                      : configured
                          ? '${l10n.adminAiConfigured(info!.model)} · ${info.keyHint}'
                          : l10n.adminAiNotConfigured,
                  style: text.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: BeaconSpace.lg),
          AppTextField(
            controller: _ctrl,
            label: l10n.adminAiKeyLabel,
            hint: l10n.adminAiKeyHint,
            obscureText: true,
            autofocus: !configured,
          ),
          const SizedBox(height: BeaconSpace.md),
          Text(l10n.adminAiKeyBody, style: text.bodySmall?.copyWith(color: t.onSurfaceMuted)),
        ],
      ),
    );
  }
}
