enum VerificationState { none, pending, approved, rejected }

/// Result of `GET /profile/verification`.
class VerificationStatus {
  final VerificationState state;
  final String? docType;
  final int? createdAtMs;
  final int? reviewedAtMs;
  final String? rejectionReason;

  const VerificationStatus({
    required this.state,
    this.docType,
    this.createdAtMs,
    this.reviewedAtMs,
    this.rejectionReason,
  });

  static const none = VerificationStatus(state: VerificationState.none);

  bool get isPending => state == VerificationState.pending;
  bool get isApproved => state == VerificationState.approved;
  bool get isRejected => state == VerificationState.rejected;

  factory VerificationStatus.fromApi(Map<String, dynamic> map) {
    final raw = map['status']?.toString();
    final state = switch (raw) {
      'pending' => VerificationState.pending,
      'approved' => VerificationState.approved,
      'rejected' => VerificationState.rejected,
      _ => VerificationState.none,
    };
    return VerificationStatus(
      state: state,
      docType: map['docType']?.toString(),
      createdAtMs: (map['createdAtMs'] as num?)?.toInt(),
      reviewedAtMs: (map['reviewedAtMs'] as num?)?.toInt(),
      rejectionReason: map['rejectionReason']?.toString(),
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
