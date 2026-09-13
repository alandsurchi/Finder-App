/// Human-readable distance from [timestampMs] to now: "Just now", "5m ago",
/// "3h ago", "2d ago", "3w ago", then a short date.
String relativeTime(int? timestampMs, {DateTime? now}) {
  if (timestampMs == null || timestampMs <= 0) return 'Just now';
  final reference = now ?? DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  final diff = reference.difference(then);

  if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final sameYear = then.year == reference.year;
  return sameYear
      ? '${then.day} ${months[then.month - 1]}'
      : '${then.day} ${months[then.month - 1]} ${then.year}';
}

/// "14:05" style clock time for chat bubbles.
String clockTime(int timestampMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
