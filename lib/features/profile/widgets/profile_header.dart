import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../data/badge_catalog.dart';

class ProfileHeader extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onTapAvatar;

  const ProfileHeader({super.key, required this.profile, this.onTapAvatar});

  @override
  Widget build(BuildContext context) {
    final pronouns = (profile.pronouns ?? '').trim();
    final hasPronouns = pronouns.isNotEmpty;

    final featuredId = (profile.featuredBadgeId ?? '').trim();
    final hasFeatured = featuredId.isNotEmpty;

    final secondaryIds = profile.secondaryBadgeIds.take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTapAvatar,
          child: const CircleAvatar(
            radius: 36,
            child: Icon(Icons.person, size: 36),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (hasPronouns) ...[
                const SizedBox(height: 4),
                Text(pronouns, style: const TextStyle(color: Colors.black54)),
              ],
              if (hasFeatured || secondaryIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                _BadgeRow(
                  featuredBadgeId: hasFeatured ? featuredId : null,
                  secondaryBadgeIds: secondaryIds,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final String? featuredBadgeId;
  final List<String> secondaryBadgeIds;

  const _BadgeRow({
    required this.featuredBadgeId,
    required this.secondaryBadgeIds,
  });

  @override
  Widget build(BuildContext context) {
    final featured = featuredBadgeId == null
        ? null
        : BadgeCatalog.byId(featuredBadgeId!);

    final secondary = secondaryBadgeIds
        .take(3)
        .map(BadgeCatalog.byId)
        .whereType<dynamic>() // filters nulls
        .toList();

    return Row(
      children: [
        if (featured != null) ...[
          _FeaturedBadge(label: featured.name),
          const SizedBox(width: 8),
        ],
        for (final b in secondary) ...[
          _SecondaryBadge(icon: b.icon),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  final String label;
  const _FeaturedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SecondaryBadge extends StatelessWidget {
  final IconData icon;
  const _SecondaryBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26),
      ),
      child: Icon(
        icon,
        size: 14,
        color: Colors.black54,
      ),
    );
  }
}

