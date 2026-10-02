import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/services/analytics/analytics_service.dart';
import 'package:finder/services/analytics/firebase_analytics_service.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Lets an admin choose the AI provider (Google AI Studio, OpenAI, Anthropic
/// or any OpenAI-compatible server) and save the key on the server from the
/// phone. The server verifies the key, stores it encrypted in the database and
/// translates the backlog of posts for everyone. Never shows the key itself.
Future<void> showAiSettingsSheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  final service = ref.read(adminConsoleServiceProvider);
  final analytics = ref.read(analyticsProvider);
  return AppBottomSheet.show<void>(
    context,
    builder: (sheetCtx) => _AiSettingsSheet(l10n: l10n, service: service, analytics: analytics),
  );
}

class _AiSettingsSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final AdminConsoleService service;
  final AnalyticsService analytics;
  const _AiSettingsSheet({required this.l10n, required this.service, required this.analytics});

  @override
  State<_AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends State<_AiSettingsSheet> {
  final _key = TextEditingController();
  final _model = TextEditingController();
  final _baseUrl = TextEditingController();
  AiSettingsInfo? _info;
  String _provider = 'google';
  bool _loading = true;
  bool _busy = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await widget.service.aiInfo();
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
        _loadError = null;
        if (info.configured) {
          _provider = info.provider;
          _model.text = info.model;
          _baseUrl.text = info.baseUrl;
        } else {
          _model.text = info.defaultModelFor(_provider);
        }
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _loadError = describeError(e); });
    }
  }

  @override
  void dispose() {
    _key.dispose();
    _model.dispose();
    _baseUrl.dispose();
    super.dispose();
  }

  void _pickProvider(String id) {
    if (_provider == id) return;
    setState(() {
      _provider = id;
      final info = _info;
      // Keep what the admin saved for this provider; otherwise use the default.
      _model.text = (info != null && info.configured && info.provider == id) ? info.model : (info?.defaultModelFor(id) ?? '');
      _baseUrl.text = (info != null && info.provider == id) ? info.baseUrl : '';
    });
  }

  Future<void> _save() async {
    final key = _key.text.trim();
    if (key.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final info = await widget.service.saveAi(
        provider: _provider,
        model: _model.text.trim(),
        key: key,
        baseUrl: _provider == 'custom' ? _baseUrl.text.trim() : '',
      );
      if (!mounted) return;
      setState(() { _info = info; _busy = false; });
      _key.clear();
      widget.analytics.logEvent(AnalyticsEvents.aiConfigured, parameters: {'provider': _provider});
      ActionFeedback.showSuccess(context, widget.l10n.adminAiSaved(info.pendingTranslations));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ActionFeedback.showError(context, describeError(e));
    }
  }

  Future<void> _remove() async {
    final l10n = widget.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminAiRemove),
        content: Text(l10n.adminAiRemoveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ctx.l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.adminAiRemove)),
        ],
      ),
    );
    if (ok != true || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      final info = await widget.service.clearAi();
      if (!mounted) return;
      setState(() {
        _info = info;
        _busy = false;
        _model.text = info.configured ? info.model : info.defaultModelFor(_provider);
      });
      ActionFeedback.showSuccess(context, l10n.adminAiRemoved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ActionFeedback.showError(context, describeError(e));
    }
  }

  String _sourceLabel(AppLocalizations l10n, String source) => switch (source) {
        'db' => l10n.adminAiSourceDb,
        'env' => l10n.adminAiSourceEnv,
        'file' => l10n.adminAiSourceEnv,
        _ => l10n.adminAiSourceNone,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final info = _info;
    final configured = info?.configured == true;
    final providers = info?.providers ?? AiSettingsInfo.fallbackProviders;
    final isCustom = _provider == 'custom';

    return AppBottomSheet(
      title: l10n.adminAiTitle,
      subtitle: l10n.adminAiSubtitle,
      actions: [
        if (configured && info?.source == 'db')
          AppButton.ghost(label: l10n.adminAiRemove, onPressed: _busy ? null : _remove)
        else
          AppButton.ghost(label: l10n.commonClose, onPressed: () => Navigator.pop(context)),
        AppButton(label: l10n.commonSave, isLoading: _busy, onPressed: _busy ? null : _save),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status
          SurfaceCard(
            padding: const EdgeInsets.all(BeaconSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  configured ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  color: configured ? t.found : t.accentDeep,
                  size: 20,
                ),
                const SizedBox(width: BeaconSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loading
                            ? l10n.commonLoading
                            : _loadError != null
                                ? _loadError!
                                : configured
                                    ? '${info!.providerLabel} · ${info.model}'
                                    : l10n.adminAiNotConfigured,
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (configured) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_sourceLabel(l10n, info!.source)} · ${info.keyHint}',
                          style: text.bodySmall?.copyWith(color: t.onSurfaceMuted),
                        ),
                        if (info.pendingTranslations > 0 || info.unscoredPending > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.adminAiBacklog(info.pendingTranslations, info.unscoredPending),
                            style: text.bodySmall?.copyWith(color: t.accentDeep),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BeaconSpace.lg),

          // ── Provider
          Text(l10n.adminAiProvider, style: text.labelLarge),
          const SizedBox(height: BeaconSpace.sm),
          Wrap(
            spacing: BeaconSpace.sm,
            runSpacing: BeaconSpace.sm,
            children: [
              for (final p in providers)
                AppChoiceChip(
                  label: p.label,
                  selected: _provider == p.id,
                  onTap: _busy ? null : () => _pickProvider(p.id),
                ),
            ],
          ),
          const SizedBox(height: BeaconSpace.md),

          if (isCustom) ...[
            AppTextField(
              controller: _baseUrl,
              label: l10n.adminAiBaseUrlLabel,
              hint: l10n.adminAiBaseUrlHint,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: BeaconSpace.md),
          ],
          AppTextField(
            controller: _model,
            label: l10n.adminAiModelLabel,
            hint: l10n.adminAiModelHint,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: BeaconSpace.md),
          AppTextField(
            controller: _key,
            label: l10n.adminAiKeyLabel,
            hint: configured ? l10n.adminAiKeyHintReplace : l10n.adminAiKeyHint,
            obscureText: true,
            autofocus: !configured,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: BeaconSpace.md),
          Text(l10n.adminAiKeyBody, style: text.bodySmall?.copyWith(color: t.onSurfaceMuted)),
        ],
      ),
    );
  }
}
