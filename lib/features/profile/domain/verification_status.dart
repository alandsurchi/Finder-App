enum VerificationState { none, pending, approved }

/// Result of `GET /profile/verification`.
class VerificationStatus {
  final VerificationState state;
  final String? docType;
  final int? createdAtMs;

  const VerificationStatus({
    required this.state,
    this.docType,
    this.createdAtMs,
  });

  static const none = VerificationStatus(state: VerificationState.none);

  bool get isPending => state == VerificationState.pending;
  bool get isApproved => state == VerificationState.approved;

  factory VerificationStatus.fromApi(Map<String, dynamic> map) {
    final raw = map['status']?.toString();
    final state = switch (raw) {
      'pending' => VerificationState.pending,
      'approved' => VerificationState.approved,
      _ => VerificationState.none,
    };
    return VerificationStatus(
      state: state,
      docType: map['docType']?.toString(),
      createdAtMs: (map['createdAtMs'] as num?)?.toInt(),
    );
  }
}

/// Payload for `POST /profile/verification`.
class VerificationRequest {
  final String docType;
  final String frontUrl;
  final String? backUrl;
  final String selfieUrl;

  const VerificationRequest({
    required this.docType,
    required this.frontUrl,
    this.backUrl,
    required this.selfieUrl,
  });

  Map<String, dynamic> toApiBody() => {
        'docType': docType,
        'frontUrl': frontUrl,
        if (backUrl != null && backUrl!.isNotEmpty) 'backUrl': backUrl,
        'selfieUrl': selfieUrl,
      };
}
