import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../l10n/l10n.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../ui/ui.dart';

/// Bottom sheet that searches members by name or e-mail and returns the
/// picked [UserSummary] (or null when dismissed).
Future<UserSummary?> showUserSearchSheet(
  BuildContext context, {
  String? title,
  String? hint,
  String? actionLabel,
}) {
  final l10n = context.l10n;
  return AppBottomSheet.show<UserSummary>(
    context,
    builder: (_) => _UserSearchSheet(
      title: title ?? l10n.profileFindMember,
      hint: hint ?? l10n.profileSearchMemberHint,
      actionLabel: actionLabel ?? l10n.profileSelect,
    ),
  );
}

class _UserSearchSheet extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final String actionLabel;
  const _UserSearchSheet({
    required this.title,
    required this.hint,
    required this.actionLabel,
  });

  @override
  ConsumerState<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<_UserSearchSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<UserSummary> _results = const [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String raw) async {
    final q = raw.trim();
    _lastQuery = q;
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final found = await ref.read(userServiceProvider).search(q);
      if (!mounted || _lastQuery != q) return;
      setState(() {
        _results = found;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || _lastQuery != q) return;
      setState(() {
        _loading = false;
        _error = failureFrom(e, fallback: context.l10n.profileSearchFailed).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final query = _ctrl.text.trim();

    return AppBottomSheet(
      title: widget.title,
      subtitle: l10n.profileSearchSubtitle,
      maxHeightFactor: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchField(
            controller: _ctrl,
            hint: widget.hint,
            autofocus: true,
            onChanged: _onChanged,
          ),
          const SizedBox(height: BeaconSpace.lg),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: BeaconSpace.xl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: BeaconSpace.lg),
              child: Text(_error!, style: text.bodyMedium?.copyWith(color: t.error)),
            )
          else if (query.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: BeaconSpace.lg),
              child: Row(
                children: [
                  Icon(Icons.person_search_outlined, color: t.onSurfaceMuted),
                  const SizedBox(width: BeaconSpace.md),
                  Expanded(
                    child: Text(
                      l10n.profileSearchBlockedNote,
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            )
          else if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: BeaconSpace.lg),
              child: Text(l10n.profileSearchNoMatch(query), style: text.bodyMedium),
            )
          else
            ..._results.map((u) => _UserRow(
                  user: u,
                  actionLabel: widget.actionLabel,
                  onTap: () => Navigator.pop(context, u),
                )),
          const SizedBox(height: BeaconSpace.md),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final UserSummary user;
  final String actionLabel;
  final VoidCallback onTap;
  const _UserRow({required this.user, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: context.l10n.profileUserRowSemantics(user.displayName, actionLabel),
      child: Material(
        color: Colors.transparent,
        borderRadius: BeaconRadius.rLg,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.sm, vertical: BeaconSpace.sm),
            child: Row(
              children: [
                AppAvatar(url: user.avatarUrl, name: user.displayName, size: 44),
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: text.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IdentityMarks(
                            verified: user.identityVerified,
                            admin: user.isAdmin,
                            size: 15,
                          ),
                        ],
                      ),
                      if (user.nickName.isNotEmpty)
                        Text('@${user.nickName}',
                            style: text.bodySmall?.copyWith(color: t.onSurfaceMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: BeaconSpace.sm),
                AppButton.tonal(
                  label: actionLabel,
                  size: AppButtonSize.small,
                  expand: false,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
