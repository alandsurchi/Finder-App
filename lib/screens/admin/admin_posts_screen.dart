import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/services/analytics/firebase_analytics_service.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: the approval queue first, then every post with moderation actions.
class AdminPostsScreen extends ConsumerStatefulWidget {
  final String initialStatus;
  const AdminPostsScreen({super.key, this.initialStatus = 'pending'});

  @override
  ConsumerState<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends ConsumerState<AdminPostsScreen> {
  static const _statuses = ['pending', 'all', 'active', 'resolved', 'rejected', 'expired', 'reported'];
  final _search = TextEditingController();
  Timer? _debounce;
  late int _tab = _statuses.indexOf(widget.initialStatus).clamp(0, _statuses.length - 1);
  String _query = '';

  String get _key => '${_statuses[_tab]}|$_query';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  void _refresh() {
    for (final s in _statuses) {
      ref.invalidate(adminPostsProvider('$s|$_query'));
    }
    ref.invalidate(adminStatsProvider);
    ref.invalidate(postsStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final posts = ref.watch(adminPostsProvider(_key));
    final pendingCount = ref.watch(adminStatsProvider).value?.pendingPosts;
    final isQueue = _statuses[_tab] == 'pending';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(title: l10n.commonPosts, subtitle: l10n.adminPostsSubtitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: Column(
                children: [
                  SearchField(
                    controller: _search,
                    hint: l10n.adminPostsSearchHint,
                    onChanged: _onQuery,
                  ),
                  const SizedBox(height: BeaconSpace.md),
                  _StatusFilters(
                    labels: [
                      pendingCount == null || pendingCount == 0
                          ? l10n.adminFilterPending
                          : l10n.adminFilterPendingCount(pendingCount),
                      l10n.adminFilterAll,
                      l10n.adminFilterOpen,
                      l10n.commonReturned,
                      l10n.adminFilterRejected,
                      l10n.adminFilterExpired,
                      l10n.adminFilterReported,
                    ],
                    selected: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Expanded(
              child: posts.when(
                loading: () => const LoadingWidget(variant: LoadingVariant.rows),
                error: (e, _) => ErrorStateWidget(message: describeError(e), onRetry: _refresh),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyWidget(
                      icon: isQueue ? Icons.rule_folder_outlined : Icons.inventory_2_outlined,
                      title: isQueue ? l10n.adminNothingToApprove : l10n.adminNoPostsHere,
                      subtitle: isQueue ? l10n.adminNothingToApproveBody : null,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.md),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return ItemCard(
                          item: item,
                          layout: ItemCardLayout.row,
                          onTap: () => item.isPending ? _review(item) : _showActions(item),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NameWithMarks(
                                name: item.ownerName ?? l10n.commonFinderUser,
                                verified: item.isVerified,
                                admin: item.ownerIsAdmin,
                                style: Theme.of(context).textTheme.labelSmall,
                                markSize: 14,
                              ),
                              if (item.isPending || item.isRejected) ...[
                                const SizedBox(height: BeaconSpace.xs),
                                Wrap(
                                  spacing: BeaconSpace.xs,
                                  runSpacing: BeaconSpace.xs,
                                  children: [
                                    StatusBadge.forStatus(item, small: true)!,
                                    if (item.isPending) _RiskPill(risk: item.aiRisk, small: true),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ItemModel item, AppLocalizations l10n) {
    if (item.isPending) return l10n.adminStatusPending;
    if (item.isRejected) return l10n.adminStatusRejected;
    if (item.isExpired) return l10n.adminStatusExpired;
    return item.isResolved ? l10n.adminStatusReturned : l10n.adminStatusOpen;
  }

  // ── Approval sheet ─────────────────────────────────────────────────────────

  void _review(ItemModel item) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final appLang = Localizations.localeOf(context).languageCode;
    final showOriginal = item.isTranslated && item.sourceLang != null && item.sourceLang != appLang;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: l10n.adminReviewTitle,
        subtitle: l10n.adminPostSheetSubtitle(
          item.ownerName ?? l10n.commonFinderUser,
          _statusLabel(item, l10n),
        ),
        actions: [
          AppButton.danger(
            label: l10n.adminReject,
            icon: Icons.block_rounded,
            onPressed: () async {
              Navigator.pop(sheetCtx);
              final reason = await _askRejectReason();
              if (reason == null || reason.isEmpty || !mounted) return;
              await _act(
                () => ref.read(adminConsoleServiceProvider).rejectPost(item.id, reason),
                l10n.adminPostRejected,
              );
              ref.read(analyticsProvider).logEvent(AnalyticsEvents.postRejected, parameters: {'risk': item.aiRisk});
            },
          ),
          AppButton(
            label: l10n.adminApprove,
            icon: Icons.check_rounded,
            onPressed: () async {
              Navigator.pop(sheetCtx);
              await _act(
                () => ref.read(adminConsoleServiceProvider).approvePost(item.id),
                l10n.adminPostApproved,
              );
              ref.read(analyticsProvider).logEvent(AnalyticsEvents.postApproved, parameters: {'risk': item.aiRisk});
            },
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.hasImage)
              ClipRRect(
                borderRadius: BeaconRadius.rLg,
                child: ItemImage(url: item.imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            if (item.hasImage) const SizedBox(height: BeaconSpace.md),
            Wrap(
              spacing: BeaconSpace.xs,
              runSpacing: BeaconSpace.xs,
              children: [
                StatusBadge.fromItem(item, small: true),
                StatusBadge.neutral(AppCategories.label(l10n, item.category), small: true),
                if (item.hasReward) StatusBadge.reward(l10n.postRewardAmount('\$${item.reward}'), small: true),
              ],
            ),
            const SizedBox(height: BeaconSpace.md),
            Text(item.title, style: text.titleMedium),
            const SizedBox(height: BeaconSpace.xs),
            Text(item.description, style: text.bodyMedium),
            if (showOriginal) ...[
              const SizedBox(height: BeaconSpace.sm),
              Text(l10n.adminOriginalText(item.sourceLang!.toUpperCase()),
                  style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
              Text(item.originalTitle, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(item.originalDescription, style: text.bodySmall),
            ],
            if (item.location.isNotEmpty) ...[
              const SizedBox(height: BeaconSpace.sm),
              Row(children: [
                Icon(Icons.place_outlined, size: 14, color: t.onSurfaceMuted),
                const SizedBox(width: BeaconSpace.xs),
                Expanded(child: Text(item.location, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ],
            const SizedBox(height: BeaconSpace.lg),
            _RiskMeter(risk: item.aiRisk, reasons: item.aiReasons),
            const SizedBox(height: BeaconSpace.md),
            SheetOption(
              icon: Icons.open_in_new_rounded,
              label: l10n.adminOpenThePost,
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item);
              },
            ),
            SheetOption(
              icon: Icons.delete_outline_rounded,
              label: l10n.adminRemoveThePost,
              subtitle: l10n.adminRemovePostOwnerNotified,
              destructive: true,
              onTap: () => _delete(sheetCtx, item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext sheetCtx, ItemModel item) async {
    final l10n = context.l10n;
    Navigator.pop(sheetCtx);
    final reason = await _askReason();
    if (reason == null || !mounted) return;
    try {
      await ref.read(adminConsoleServiceProvider).deletePost(item.id, reason: reason);
      if (!mounted) return;
      ActionFeedback.showSuccess(context, l10n.adminPostRemoved);
      _refresh();
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
  }

  Future<String?> _askRejectReason() {
    final l10n = context.l10n;
    final ctrl = TextEditingController();
    return AppBottomSheet.show<String>(
      context,
      builder: (ctx) => AppBottomSheet(
        title: l10n.adminRejectPostTitle,
        subtitle: l10n.adminRejectPostSubtitle,
        actions: [
          AppButton.ghost(label: l10n.commonCancel, onPressed: () => Navigator.pop(ctx)),
          AppButton.danger(
            label: l10n.adminReject,
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
        child: AppTextField(
          controller: ctrl,
          label: l10n.adminReasonLabel,
          hint: l10n.adminRejectPostHint,
          autofocus: true,
          maxLines: 3,
        ),
      ),
    );
  }

  Future<void> _act(Future<void> Function() action, String success) async {
    try {
      await action();
      if (!mounted) return;
      ActionFeedback.showSuccess(context, success);
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
    if (mounted) _refresh();
  }

  // ── Actions for live / returned / rejected posts ───────────────────────────

  void _showActions(ItemModel item) {
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: item.title,
        subtitle: l10n.adminPostSheetSubtitle(
          item.ownerName ?? l10n.commonFinderUser,
          _statusLabel(item, l10n),
        ),
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isRejected && (item.rejectionReason ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: BeaconSpace.md),
                child: Text(
                  l10n.postRejectedReason(item.rejectionReason!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            SheetOption(
              icon: Icons.open_in_new_rounded,
              label: l10n.adminOpenThePost,
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item);
              },
            ),
            if (!item.isUnderReview)
              SheetOption(
                icon: item.isActive ? Icons.assignment_turned_in_outlined : Icons.replay_rounded,
                label: item.isActive ? l10n.commonMarkAsReturned : l10n.adminReopenThePost,
                onTap: () => _run(
                  sheetCtx,
                  () => ref.read(adminConsoleServiceProvider).setPostStatus(
                      item.id, item.isActive ? 'resolved' : 'active'),
                  item.isActive ? l10n.commonMarkedAsReturned : l10n.adminPostReopened,
                ),
              ),
            if (item.isRejected)
              SheetOption(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.adminApproveAgain,
                subtitle: l10n.adminApproveAgainSubtitle,
                onTap: () => _run(
                  sheetCtx,
                  () => ref.read(adminConsoleServiceProvider).approvePost(item.id),
                  l10n.adminPostApproved,
                ),
              )
            else
              SheetOption(
                icon: Icons.block_rounded,
                label: l10n.adminTakeDown,
                subtitle: l10n.adminTakeDownSubtitle,
                destructive: true,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final reason = await _askRejectReason();
                  if (reason == null || reason.isEmpty || !mounted) return;
                  await _act(
                    () => ref.read(adminConsoleServiceProvider).rejectPost(item.id, reason),
                    l10n.adminPostTakenDown,
                  );
                },
              ),
            SheetOption(
              icon: Icons.delete_outline_rounded,
              label: l10n.adminRemoveThePost,
              subtitle: l10n.adminRemovePostOwnerNotified,
              destructive: true,
              onTap: () => _delete(sheetCtx, item),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  Future<String?> _askReason() {
    final l10n = context.l10n;
    final ctrl = TextEditingController();
    return AppBottomSheet.show<String>(
      context,
      builder: (ctx) => AppBottomSheet(
        title: l10n.adminRemovePostTitle,
        subtitle: l10n.adminRemovePostReasonSubtitle,
        actions: [
          AppButton.ghost(label: l10n.commonCancel, onPressed: () => Navigator.pop(ctx)),
          AppButton.danger(
            label: l10n.commonRemove,
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
        child: AppTextField(
          controller: ctrl,
          label: l10n.adminReasonOptionalLabel,
          hint: l10n.adminReasonPostHint,
          autofocus: true,
          maxLines: 3,
        ),
      ),
    );
  }

  Future<void> _run(BuildContext sheetCtx, Future<void> Function() action, String success) async {
    Navigator.pop(sheetCtx);
    try {
      await action();
      if (!mounted) return;
      ActionFeedback.showSuccess(context, success);
      _refresh();
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
  }
}

/// Colour rule for the AI score: green under 30, amber to 69, red from 70.
Color riskColor(AppColorTokens t, int? risk) {
  if (risk == null) return t.onSurfaceMuted;
  if (risk < 30) return t.found;
  if (risk < 70) return t.accentDeep;
  return t.lost;
}

class _RiskPill extends StatelessWidget {
  final int? risk;
  final bool small;
  const _RiskPill({required this.risk, this.small = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    return StatusBadge.custom(
      label: risk == null ? l10n.adminRiskUnavailable : l10n.adminRiskLabel(risk!),
      color: riskColor(t, risk),
      small: small,
    );
  }
}

class _RiskMeter extends StatelessWidget {
  final int? risk;
  final List<String> reasons;
  const _RiskMeter({required this.risk, required this.reasons});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final color = riskColor(t, risk);
    final verdict = risk == null
        ? l10n.adminRiskUnavailable
        : risk! < 30
            ? l10n.adminRiskLow
            : risk! < 70
                ? l10n.adminRiskMedium
                : l10n.adminRiskHigh;
    return SurfaceCard(
      tone: SurfaceTone.low,
      border: false,
      padding: const EdgeInsets.all(BeaconSpace.md),
      radius: BeaconRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 16, color: color),
              const SizedBox(width: BeaconSpace.xs),
              Text(
                risk == null ? l10n.adminRiskUnavailable : l10n.adminRiskLabel(risk!),
                style: text.labelLarge?.copyWith(color: color),
              ),
              const Spacer(),
              Text(verdict, style: text.labelSmall?.copyWith(color: t.onSurfaceVar)),
            ],
          ),
          const SizedBox(height: BeaconSpace.sm),
          ClipRRect(
            borderRadius: BeaconRadius.rPill,
            child: LinearProgressIndicator(
              value: (risk ?? 0) / 100,
              minHeight: 6,
              color: color,
              backgroundColor: t.surfaceHigh,
            ),
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: BeaconSpace.sm),
            Wrap(
              spacing: BeaconSpace.xs,
              runSpacing: BeaconSpace.xs,
              children: [for (final r in reasons) StatusBadge.neutral(r, small: true)],
            ),
          ],
        ],
      ),
    );
  }
}

/// Status filters: one row of pills that scrolls sideways, each sized to its
/// label, with a gap between them (the equal-width segmented control squashed
/// seven labels together).
class _StatusFilters extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const _StatusFilters({required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: BeaconSpace.sm),
        itemBuilder: (context, i) => Center(
          child: AppChoiceChip(
            label: labels[i],
            selected: i == selected,
            onTap: () => onChanged(i),
          ),
        ),
      ),
    );
  }
}
