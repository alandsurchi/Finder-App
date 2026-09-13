# Finder — Beacon Design System

> A lost-and-found app is a beacon that guides things home. Calm, editorial,
> with one hopeful signal color. Android-first Material 3, iOS and web friendly.

## 1. Recognition anchors

If you screenshot any screen without the logo, you know it is Finder by:

1. **Signal spine** — every feed card is a "photo on paper" with a 30dp
   colored spine on its leading edge carrying a vertical LOST / FOUND label:
   coral for *Lost*, emerald for *Found*. Row and compact cards keep a 6dp
   rail. The same two colors drive every badge and the Home hero tiles
   (`lib/widgets/ui/item_card.dart`, `status_badge.dart`).
2. **Beacon glow + rings** — a warm amber radial glow with a hairline radar
   ring texture behind auth, onboarding, the profile cover and empty states
   (`lib/widgets/ui/beacon_glow.dart`). Loading is a `BeaconPulse` radar,
   never a bare spinner.
3. **Lit CTAs and the notch nav** — primary and accent buttons carry a
   vertical gradient, hairline top highlight and a colored shadow; the nav's
   active destination floats in the notch as a gradient disc wrapped in a
   breathing amber ring (`lib/widgets/custom_bottom_nav_bar.dart`).

## 2. Color

Tokens live in `lib/theme/beacon_colors.dart` (a `ThemeExtension`) and are
read through `AppColorTokens.of(context)`. Never write hex values in widgets.

| Role | Daylight (light) | Nightwatch (dark) |
|---|---|---|
| bg | `#F6F5F1` warm paper | `#0B1213` deep ink |
| surfaceLow / surface / surfaceHigh | `#EFEDE7` / `#FFFFFF` / `#E6E3DB` | `#0F1819` / `#121B1D` / `#1A2528` |
| primary / onPrimary | `#0B6E6A` / `#FFFFFF` | `#5FD4CB` / `#062A28` |
| primaryContainer | `#D7F0EC` | `#163B39` |
| accent (beacon amber) / onAccent | `#F2A33A` / `#3B2300` | `#F5B45C` / `#2B1A00` |
| lost / lostContainer | `#D9483B` / `#FBE4E1` | `#FF7A6B` / `#3A1A16` |
| found / foundContainer | `#1E8E5A` / `#DDF3E7` | `#4ADE80` / `#143A24` |
| onSurface / onSurfaceVariant | `#17201F` / `#5A6664` | `#E6EBE9` / `#93A29F` |
| outline / outlineVariant | `#C9CFCB` / `#E1E5E2` | white 10% / white 6% |
| error / errorContainer | `#C62828` / `#FBE3E1` | `#FF6B6B` / `#3A1616` |

Rules:
- Body text uses `onSurface`; secondary text uses `onSurfaceVariant`
  (≥ 4.5:1 on all surfaces). `onSurfaceMuted` is for hints and captions only.
- Depth comes from surface tone (low → base → high), not shadows. Light mode
  cards may use one ambient shadow (6% alpha, 24 blur); dark mode uses a
  hairline `outlineVariant` border instead.
- Amber is a *signal*, not a brand color: rewards, the glow, the nav ring,
  progress. Never use it for body text.
- Legacy names still compile: `divider`→outline, `warning`→accent,
  `success`→found, `iconBg`→primaryContainer, `errorSurface`→errorContainer.

## 3. Typography

Defined once in `lib/theme/app_theme.dart`; read via
`Theme.of(context).textTheme`. Never set `fontSize` inline.

| Style | Font | Size / weight | Use |
|---|---|---|---|
| displayLarge…Small | Sora | 44/36/30 · 700 | hero moments |
| headlineLarge / Medium / Small | Sora | 28/24/20 · 700/700/600 | screen titles |
| titleLarge | Sora | 18 · 600 | card titles, section headers |
| titleMedium / Small | Inter | 16/14 · 600 | list titles, field labels |
| bodyLarge / Medium / Small | Inter | 16/14/12 · 400 | prose (line-height 1.5) |
| labelLarge / Medium / Small | Inter | 14/12/11 · 600 | buttons, chips, eyebrows |

## 4. Scales (`lib/theme/beacon_tokens.dart`)

- **Spacing** `BeaconSpace`: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40. Page gutter 20.
- **Radius** `BeaconRadius`: 8 · 12 · 16 · 20 · 24 · pill.
- **Motion** `BeaconMotion`: press 120ms · state 220ms · enter 360ms
  (`easeOutCubic`) · exit 160ms. Always wrap durations in
  `BeaconMotion.scaled(context, d)` so reduced-motion collapses them to zero.
- **Touch** ≥ 48dp for every interactive element (`kBeaconTouchTarget`).

## 5. Components (`lib/widgets/ui/`)

| Component | Purpose |
|---|---|
| `AppButton` (primary / secondary / tonal / ghost / danger / accent) | The only CTA. Pill, 52dp, `isLoading` keeps width. |
| `AppIconButton` | Icon-only actions; `tooltip` is required (accessible name). |
| `AppTextField`, `AppPickerField` | Labeled inputs; built-in password toggle. |
| `SurfaceCard`, `GlassCard` | Tonal containers; glass for floating chrome. |
| `StatusBadge`, `SignalRail`, `SignalKind` | LOST / FOUND / REWARD / RESOLVED / VERIFIED. |
| `ItemCard` (tile / row / compact) | Every post card. `HomeItemCard`, `SavedCard`, `SimilarCard`, My-posts and Search rows sit on it. |
| `ItemImage`, `AppAvatar` | Network/asset images with tokenized fallbacks and fade-in. |
| `AppPageHeader`, `SectionHeader` | Screen and section titles with 48dp back button. |
| `SearchField`, `AppChoiceChip`, `SegmentedPills` | Filtering. |
| `SettingsGroup`, `SettingsTile`, `ToggleTile` | Settings and menus. |
| `AppBottomSheet`, `SheetOption` | Sheet chrome with grabber and pinned actions. |
| `Skeleton`, `SkeletonItemList` | Loading placeholders (`LoadingWidget(variant:)`). |
| `StaggeredEntrance` | Fade-rise entrance; timer-free and reduced-motion aware. |
| `LostFoundTypeTile`, `MapPlaceholder`, `BeaconGlow`, `BeaconMark`, `AuthShell` | Feature pieces. |

State widgets: `LoadingWidget`, `EmptyWidget`, `ErrorStateWidget` in
`lib/widgets/state/`. Snackbars: `ActionFeedback.showInfo/Success/Error`.

## 6. Do / Don't

**Do**
- One primary CTA per screen, in the thumb zone.
- Label every icon-only control (`tooltip` / `Semantics`).
- Reserve bottom padding for the notch nav on tab pages:
  `CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg`.
- Design light and dark together; check contrast in both.

**Don't**
- Hardcode `Colors.*` or `Color(0x…)` in screens or widgets.
- Use inline `TextStyle(fontSize: …)`.
- Add a second badge color rule, a second card, or a second button style.
- Animate width/height; animate opacity and transform.

## 7. Previewing

`flutter run -d chrome -t lib/dev/preview_main.dart` runs the UI against
in-memory sample data (no backend). Add `?theme=dark` or
`?screen=item-details` to the URL to jump into a theme or route.
