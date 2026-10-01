# Localization (English, Arabic, Kurdish Sorani)

The app ships in three languages. Arabic (`ar`) and Central Kurdish (`ckb`) are
right-to-left; Flutter mirrors the layout automatically once the locale is set.

## Where the strings live

| What | Where |
|---|---|
| English source of truth | `tool/l10n/seed_en.arb` (shared strings) + `tool/l10n/fragments/*.arb` (one per app area) |
| Translations | `tool/l10n/ar/*.arb`, `tool/l10n/ckb/*.arb` (same keys, same file names) |
| Server error messages | `tool/l10n/fragments/server.arb` + `lib/core/network/server_messages.dart` (English → key map) |
| Generated ARB files | `lib/l10n/app_en.arb`, `app_ar.arb`, `app_ckb.arb` — **never edit by hand** |
| Generated Dart | `lib/l10n/generated/` (from `flutter gen-l10n`, config in `l10n.yaml`) |

Rebuild everything with:

```bash
python tool/merge_l10n.py
```

It merges the fragments, reports duplicate keys that disagree, lists missing
or stale translations per language, and runs `flutter gen-l10n`.
`flutter pub get` also regenerates the Dart code (`generate: true` in pubspec).

## Using strings in code

```dart
import 'package:finder/l10n/l10n.dart';

Text(context.l10n.postDeleteTitle)          // in widgets
throw ValidationException(L10n.current.photoTooLarge);   // services, no context
```

- Keys are camelCase with an area prefix (`chat…`, `post…`, `auth…`, `admin…`,
  `common…`, `server…`). Reuse `common*` keys for shared words.
- Placeholders: `l10n.chatBlockTitle(name)`; plurals use ICU syntax in the ARB.
- Dates: `relativeTime(ms, l10n: context.l10n)` and `shortDate(...)` in
  `lib/core/utils/relative_time.dart`. Month and weekday names come from
  `commonMonthShort` / `commonWeekdayShort`. Digits stay Western (0-9).

## Right-to-left rules

Use directional values instead of physical sides so the same code mirrors:
`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`,
`BorderRadiusDirectional`, `TextAlign.start/end`. Gestures that depend on a
side (swipe to reply, slide to cancel) multiply their delta by
`context.isRtl ? -1 : 1`. Material icons such as `arrow_back`, `chevron_right`,
`send`, `reply` and `help_outline` mirror on their own.

## Kurdish support

Flutter has no built-in `ckb` localizations, so `lib/l10n/kurdish_localizations.dart`
provides them: Kurdish labels for dialogs, pickers and the text-selection
menu, Kurdish month and weekday names (weeks start on Saturday), RTL text
direction, and Arabic as the fallback for the few Cupertino strings.

## Fonts

Latin text uses Sora and Inter (bundled). Arabic-script locales switch the whole
text theme to **Vazirmatn**, which covers Arabic and the Kurdish letters
(ڕ ڵ ێ ۆ ڤ). Line height is raised and letter spacing is zeroed because joined
scripts break with negative tracking. Bundle the font files under
`assets/google_fonts/` (`Vazirmatn-Regular.ttf`, `-Medium`, `-SemiBold`, `-Bold`)
so nothing is fetched at runtime; until then google_fonts downloads them once
and caches them on the device.

## Choosing the language

Settings → Preferences → Language, or the translate button on the onboarding
screen. The choice is stored in SharedPreferences (`app_language`) and read
before the first frame. "Use phone language" follows the device: Android reports
Sorani as `ckb` (older devices `ku`).

## Adding a string

1. Add the key to the right fragment in `tool/l10n/fragments/`.
2. Add the Arabic and Kurdish text to the matching file in `tool/l10n/ar/` and `tool/l10n/ckb/`.
3. Run `python tool/merge_l10n.py` and use `context.l10n.yourKey`.
