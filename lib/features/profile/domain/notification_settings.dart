/// Which events create notifications for the user (`/profile/notification-settings`).
class NotificationSettings {
  final bool messages;
  final bool matches;
  final bool updates;
  final bool marketing;
  final bool email;

  const NotificationSettings({
    required this.messages,
    required this.matches,
    required this.updates,
    required this.marketing,
    required this.email,
  });

  static const defaults = NotificationSettings(
    messages: true,
    matches: true,
    updates: true,
    marketing: false,
    email: true,
  );

  factory NotificationSettings.fromApi(Map<String, dynamic> map) =>
      NotificationSettings(
        messages: map['messages'] as bool? ?? defaults.messages,
        matches: map['matches'] as bool? ?? defaults.matches,
        updates: map['updates'] as bool? ?? defaults.updates,
        marketing: map['marketing'] as bool? ?? defaults.marketing,
        email: map['email'] as bool? ?? defaults.email,
      );

  Map<String, dynamic> toApiBody() => {
        'messages': messages,
        'matches': matches,
        'updates': updates,
        'marketing': marketing,
        'email': email,
      };

  NotificationSettings copyWith({
    bool? messages,
    bool? matches,
    bool? updates,
    bool? marketing,
    bool? email,
  }) {
    return NotificationSettings(
      messages: messages ?? this.messages,
      matches: matches ?? this.matches,
      updates: updates ?? this.updates,
      marketing: marketing ?? this.marketing,
      email: email ?? this.email,
    );
  }
}
