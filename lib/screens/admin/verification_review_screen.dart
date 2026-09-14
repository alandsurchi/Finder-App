import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/admin/admin_service.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: one request, document and selfie side by side, approve or reject.
class VerificationReviewScreen extends ConsumerStatefulWidget {
  final AdminVerificationRequest request;
  const VerificationReviewScreen({super.key, required this.request});

  @override
  ConsumerState<VerificationReviewScreen> createState() =>
      _VerificationReviewScreenState();
}

class _VerificationReviewScreenState
    extends ConsumerState<VerificationReviewScreen> {
  bool _busy = false;

  AdminVerificationRequest get r => widget.request;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: r.isPending ? _buildActions(t) : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(title: r.userName, subtitle: r.email),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(BeaconSpace.page, 0, BeaconSpace.page,
                    BeaconSpace.xxl + MediaQuery.paddingOf(context).bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SurfaceCard(
                      child: Row(
                        children: [
                          AppAvatar(url: r.avatarUrl, name: r.userName, size: 48),
                          const SizedBox(width: BeaconSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${r.docLabel} · submitted ${relativeTime(r.createdAtMs)}',
                                    style: text.bodyMedium),
                                if (r.reviewedAtMs != null)
                                  Text(
                                    '${r.status} ${relativeTime(r.reviewedAtMs)}',
                                    style: text.bodySmall,
                                  ),
                                if (r.rejectionReason != null &&
                                    r.rejectionReason!.isNotEmpty)
                                  Text('Reason: ${r.rejectionReason}',
                                      style: text.bodySmall?.copyWith(color: t.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: BeaconSpace.xl),
                    const SectionHeader(title: 'Document', eyebrow: 'Step 1'),
                    _photo('front', r.hasBack ? 'Front of ID' : 'Photo page'),
                    if (r.hasBack) ...[
                      const SizedBox(height: BeaconSpace.md),
                      _photo('back', 'Back of ID'),
                    ],
                    const SizedBox(height: BeaconSpace.xl),
                    const SectionHeader(title: 'Live selfie', eyebrow: 'Step 2'),
                    _photo('selfie', 'Selfie taken with the front camera'),
                    const SizedBox(height: BeaconSpace.lg),
                    Text(
                      'Compare the face on the document with the selfie, check the name matches the account, and that the document is not expired or edited.',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo(String slot, String caption) {
    final text = Theme.of(context).textTheme;
    final path = r.filePath(slot);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _zoom(path, caption),
          child: AuthImage(
            path: path,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BeaconRadius.rLg,
          ),
        ),
        const SizedBox(height: BeaconSpace.xs),
        Text('$caption · tap to zoom', style: text.bodySmall),
      ],
    );
  }

  void _zoom(String path, String caption) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 6,
                child: Center(
                  child: AuthImage(path: path, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  variant: AppIconButtonVariant.filled,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(AppColorTokens t) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.lg),
          child: Row(
            children: [
              Expanded(
                child: AppButton.tonal(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  size: AppButtonSize.medium,
                  onPressed: _busy ? null : _reject,
                ),
              ),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: AppButton(
                  label: 'Approve',
                  icon: Icons.verified_rounded,
                  size: AppButtonSize.medium,
                  isLoading: _busy,
                  onPressed: _busy ? null : _approve,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approve() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve this identity?'),
        content: Text('${r.userName} gets the verified badge and a notification.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => ref.read(adminServiceProvider).approve(r.id), 'Identity approved.');
  }

  Future<void> _reject() async {
    final ctrl = TextEditingController();
    final reason = await AppBottomSheet.show<String>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: 'Reject request',
        subtitle: 'The reason is sent to ${r.userName} so they can fix it.',
        actions: [
          AppButton.ghost(
            label: 'Cancel',
            size: AppButtonSize.medium,
            onPressed: () => Navigator.pop(sheetCtx),
          ),
          AppButton.danger(
            label: 'Reject',
            size: AppButtonSize.medium,
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.length < 3) return;
              Navigator.pop(sheetCtx, v);
            },
          ),
        ],
        child: AppTextField(
          controller: ctrl,
          label: 'Reason',
          hint: 'e.g. The selfie is too dark to compare with the document.',
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
    if (reason == null || reason.isEmpty) return;
    await _run(() => ref.read(adminServiceProvider).reject(r.id, reason), 'Request rejected.');
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ActionFeedback.showSuccess(context, success);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ActionFeedback.showError(context, describeError(e));
    }
  }
}
