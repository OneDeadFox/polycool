class Profile {
  final String displayName;
  final String? pronouns;

  /// Badge id for the featured badge (e.g. "clear_communicator"). Optional.
  final String? featuredBadgeId;

  /// Up to 3 secondary badge ids.
  final List<String> secondaryBadgeIds;

  const Profile({
    required this.displayName,
    this.pronouns,
    this.featuredBadgeId,
    this.secondaryBadgeIds = const [],
  });
}
