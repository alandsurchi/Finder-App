import '../../l10n/l10n.dart';

/// Human-readable distance from [timestampMs] to now: "Just now", "5m ago",
/// "3h ago", "2d ago", "3w ago", then a short date. Pass the screen's
/// [l10n] (`context.l10n`); without it the current app language is used.
String relativeTime(int? timestampMs, {DateTime? now, AppLocalizations? l10n}) {
  final s = l10n ?? L10n.current;
  if (timestampMs == null || timestampMs <= 0) return s.commonJustNow;
  final reference = now ?? DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  final diff = reference.difference(then);

  if (diff.isNegative || diff.inMinutes < 1) return s.commonJustNow;
  if (diff.inMinutes < 60) return s.commonMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return s.commonHoursAgo(diff.inHours);
  if (diff.inDays < 7) return s.commonDaysAgo(diff.inDays);
  if (diff.inDays < 30) return s.commonWeeksAgo((diff.inDays / 7).floor());
  return shortDate(then, reference: reference, l10n: s);
}

/// "14 Mar" this year, "14 Mar 2025" otherwise, in the app language.
String shortDate(DateTime date, {DateTime? reference, AppLocalizations? l10n}) {
  final s = l10n ?? L10n.current;
  final ref = reference ?? DateTime.now();
  final month = s.commonMonthShort('${date.month}');
  return date.year == ref.year
      ? s.commonDayMonth(date.day, month)
      : s.commonDayMonthYear(date.day, month, date.year);
}

/// "14:05" style clock time for chat bubbles.
String clockTime(int timestampMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
