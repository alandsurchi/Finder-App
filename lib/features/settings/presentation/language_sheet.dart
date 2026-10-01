import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/locale_controller.dart';
import '../../../widgets/ui/ui.dart';

/// Picks the app language. Each option is written in its own language so
/// a user who cannot read the current one still finds theirs.
Future<void> showLanguageSheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  final current = ref.read(localeControllerProvider);
  return AppBottomSheet.show<void>(
    context,
    builder: (sheetCtx) => AppBottomSheet(
      title: l10n.languageTitle,
      subtitle: l10n.languageSubtitle,
      scrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetOption(
            icon: Icons.phone_android_rounded,
            label: l10n.languageSystem,
            selected: current == null,
            onTap: () {
              Navigator.pop(sheetCtx);
              ref.read(localeControllerProvider.notifier).set(null);
            },
          ),
          for (final lang in AppLanguage.values)
            SheetOption(
              icon: Icons.translate_rounded,
              label: lang.nativeName,
              selected: current?.languageCode == lang.locale.languageCode,
              onTap: () {
                Navigator.pop(sheetCtx);
                ref.read(localeControllerProvider.notifier).set(lang);
              },
            ),
          const SizedBox(height: BeaconSpace.lg),
        ],
      ),
    ),
  );
}

/// Native name of the language in use, for the settings row subtitle.
String currentLanguageLabel(BuildContext context, Locale? chosen) {
  final l10n = context.l10n;
  if (chosen == null) {
    final active = Localizations.localeOf(context);
    final lang = AppLanguage.fromCode(active.languageCode) ?? AppLanguage.english;
    return '${l10n.languageSystem} · ${lang.nativeName}';
  }
  return AppLanguage.fromCode(chosen.languageCode)?.nativeName ?? l10n.languageEnglish;
}
