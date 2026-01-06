enum NominationStatus {
  offered,   // nominated, not decided yet
  accepted,  // accepted (may be displayed or hidden)
  declined,  // declined but can accept later if still eligible
}

class BadgeNomination {
  final String badgeId;
  final DateTime nominatedAt;
  final NominationStatus status;

  const BadgeNomination({
    required this.badgeId,
    required this.nominatedAt,
    required this.status,
  });

  BadgeNomination copyWith({
    NominationStatus? status,
  }) {
    return BadgeNomination(
      badgeId: badgeId,
      nominatedAt: nominatedAt,
      status: status ?? this.status,
    );
  }
}
