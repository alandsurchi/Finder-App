class PrivacySettings {
  final bool showProfile;
  final bool allowMessages;
  final bool showLocation;
  final bool hidePhone;

  const PrivacySettings({
    required this.showProfile,
    required this.allowMessages,
    required this.showLocation,
    required this.hidePhone,
  });

  PrivacySettings copyWith({
    bool? showProfile,
    bool? allowMessages,
    bool? showLocation,
    bool? hidePhone,
  }) {
    return PrivacySettings(
      showProfile: showProfile ?? this.showProfile,
      allowMessages: allowMessages ?? this.allowMessages,
      showLocation: showLocation ?? this.showLocation,
      hidePhone: hidePhone ?? this.hidePhone,
    );
  }
}
