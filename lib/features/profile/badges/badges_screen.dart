import 'package:flutter/material.dart';

import '../data/badge_catalog.dart';
import '../models/badge.dart';
import '../models/badge_nomination.dart';
import '../models/profile.dart';

class BadgesScreen extends StatefulWidget {
  final Profile profile;

  const BadgesScreen({super.key, required this.profile});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  // Local fake state for v1:
  // - displayedFeaturedId + displayedSecondaryIds control what viewers see
  // - acceptedHiddenIds are accepted but not displayed
  // - nominations includes declined/offered badges
  late String? displayedFeaturedId;
  late List<String> displayedSecondaryIds;
  final Set<String> acceptedHiddenIds = {};

  late List<BadgeNomination> nominations;

  Future<void> _pickDisplaySlotAndAccept(String badgeId) async {
    final choice = await showModalBottomSheet<_BadgeDisplayChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _BadgeDisplayPicker(
          badgeId: badgeId,
          featuredId: displayedFeaturedId,
          secondaryIds: displayedSecondaryIds,
        );
      },
    );

    if (choice == null) return;

    setState(() {
      // Mark nomination accepted
      nominations = nominations
          .map(
            (n) => n.badgeId == badgeId
                ? n.copyWith(status: NominationStatus.accepted)
                : n,
          )
          .toList();

      // Apply choice
      switch (choice.kind) {
        case _BadgeDisplayKind.private:
          acceptedHiddenIds.add(badgeId);
          break;

        case _BadgeDisplayKind.featured:
          // If badge was already in secondary, remove it
          displayedSecondaryIds.remove(badgeId);
          // Featured slot replaces current featured
          displayedFeaturedId = badgeId;
          // Remove from hidden if present
          acceptedHiddenIds.remove(badgeId);
          break;

        case _BadgeDisplayKind.secondary:
          // Ensure not featured
          if (displayedFeaturedId == badgeId) {
            displayedFeaturedId = null;
          }
          // Remove if already exists
          displayedSecondaryIds.remove(badgeId);

          // Place into requested index (0..2)
          final index = choice.secondaryIndex!;
          while (displayedSecondaryIds.length < 3) {
            displayedSecondaryIds.add(''); // temporary placeholder
          }
          displayedSecondaryIds[index] = badgeId;

          // Clean empty placeholders
          displayedSecondaryIds = displayedSecondaryIds
              .where((id) => id.trim().isNotEmpty)
              .toList();

          acceptedHiddenIds.remove(badgeId);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    displayedFeaturedId = widget.profile.featuredBadgeId;
    displayedSecondaryIds = widget.profile.secondaryBadgeIds.take(3).toList();

    // Example nomination list (fake):
    nominations = [
      BadgeNomination(
        badgeId: 'open_to_feedback',
        nominatedAt: DateTime.now().subtract(const Duration(days: 8)),
        status: NominationStatus.offered,
      ),
      BadgeNomination(
        badgeId: 'supportive_member',
        nominatedAt: DateTime.now().subtract(const Duration(days: 20)),
        status: NominationStatus.declined,
      ),
    ];
  }

  void acceptBadge(String badgeId, {required bool display}) {
    setState(() {
      nominations = nominations
          .map(
            (n) => n.badgeId == badgeId
                ? n.copyWith(status: NominationStatus.accepted)
                : n,
          )
          .toList();

      if (display) {
        // If no featured badge yet, make it featured. Otherwise add to secondary if space.
        if (displayedFeaturedId == null || displayedFeaturedId!.isEmpty) {
          displayedFeaturedId = badgeId;
        } else if (!displayedSecondaryIds.contains(badgeId) &&
            displayedSecondaryIds.length < 3) {
          displayedSecondaryIds.add(badgeId);
        } else {
          // If no display slot, keep accepted but hidden.
          acceptedHiddenIds.add(badgeId);
        }
      } else {
        acceptedHiddenIds.add(badgeId);
      }
    });
  }

  void hideDisplayedBadge(String badgeId) {
    setState(() {
      if (displayedFeaturedId == badgeId) {
        displayedFeaturedId = null;
      }
      displayedSecondaryIds.remove(badgeId);
      acceptedHiddenIds.add(badgeId);
    });
  }

  void declineBadge(String badgeId) {
    setState(() {
      nominations = nominations
          .map(
            (n) => n.badgeId == badgeId
                ? n.copyWith(status: NominationStatus.declined)
                : n,
          )
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Declined. You can accept later from this page.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = displayedFeaturedId == null
        ? null
        : BadgeCatalog.byId(displayedFeaturedId!);

    final secondary = displayedSecondaryIds
        .map(BadgeCatalog.byId)
        .whereType<AppBadge>()
        .toList();

    final acceptedHidden = acceptedHiddenIds
        .map(BadgeCatalog.byId)
        .whereType<AppBadge>()
        .toList();

    final offered = nominations
        .where((n) => n.status == NominationStatus.offered)
        .toList();

    final declined = nominations
        .where((n) => n.status == NominationStatus.declined)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Displayed badges',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          if (featured != null)
            _BadgeCard(
              badge: featured,
              trailing: TextButton(
                onPressed: () => hideDisplayedBadge(featured.id),
                child: const Text('Hide'),
              ),
              subtitle: 'Featured badge (shown on your profile)',
            )
          else
            const Text(
              'No featured badge displayed.',
              style: TextStyle(color: Colors.black54),
            ),

          const SizedBox(height: 10),

          if (secondary.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final b in secondary)
                  _BadgeChip(
                    label: b.name,
                    onPressed: () => hideDisplayedBadge(b.id),
                  ),
              ],
            )
          else
            const Text(
              'No secondary badges displayed.',
              style: TextStyle(color: Colors.black54),
            ),

          const SizedBox(height: 22),

          Text(
            'Accepted but hidden',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (acceptedHidden.isEmpty)
            const Text('None.', style: TextStyle(color: Colors.black54))
          else
            Column(
              children: [
                for (final b in acceptedHidden) ...[
                  _BadgeCard(badge: b, subtitle: 'Accepted, not displayed'),
                  const SizedBox(height: 10),
                ],
              ],
            ),

          const SizedBox(height: 22),

          Text('Nominations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          if (offered.isEmpty)
            const Text(
              'No new nominations right now.',
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              children: [
                for (final n in offered) ...[
                  _NominationCard(
                    badgeId: n.badgeId,
                    onAcceptDisplay: () => _pickDisplaySlotAndAccept(n.badgeId),
                    onAcceptPrivate: () =>
                        acceptBadge(n.badgeId, display: false),
                    onDecline: () => declineBadge(n.badgeId),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),

          const SizedBox(height: 18),

          Text(
            'Previously declined',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          if (declined.isEmpty)
            const Text('None.', style: TextStyle(color: Colors.black54))
          else
            Column(
              children: [
                for (final n in declined) ...[
                  _DeclinedCard(
                    badgeId: n.badgeId,
                    onAccept: () => acceptBadge(n.badgeId, display: true),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final AppBadge badge;
  final String? subtitle;
  final Widget? trailing;

  const _BadgeCard({required this.badge, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Icon(badge.icon),
        title: Text(badge.name),
        subtitle: Text(subtitle ?? badge.description),
        trailing: trailing,
      ),
    );
  }
}

class _NominationCard extends StatelessWidget {
  final String badgeId;
  final VoidCallback onAcceptDisplay;
  final VoidCallback onAcceptPrivate;
  final VoidCallback onDecline;

  const _NominationCard({
    required this.badgeId,
    required this.onAcceptDisplay,
    required this.onAcceptPrivate,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final badge = BadgeCatalog.byId(badgeId);
    if (badge == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              badge.description,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: onAcceptDisplay,
                  child: const Text('Accept & display'),
                ),
                OutlinedButton(
                  onPressed: onAcceptPrivate,
                  child: const Text('Accept (private)'),
                ),
                TextButton(
                  onPressed: onDecline,
                  child: const Text('Decline for now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeclinedCard extends StatelessWidget {
  final String badgeId;
  final VoidCallback onAccept;

  const _DeclinedCard({required this.badgeId, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final badge = BadgeCatalog.byId(badgeId);
    if (badge == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Icon(badge.icon),
        title: Text(badge.name),
        subtitle: const Text(
          'Previously declined — you can accept later if it still fits.',
        ),
        trailing: TextButton(onPressed: onAccept, child: const Text('Accept')),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BadgeChip({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onPressed);
  }
}

enum _BadgeDisplayKind { featured, secondary, private }

class _BadgeDisplayChoice {
  final _BadgeDisplayKind kind;
  final int? secondaryIndex;

  const _BadgeDisplayChoice.featured()
    : kind = _BadgeDisplayKind.featured,
      secondaryIndex = null;

  const _BadgeDisplayChoice.private()
    : kind = _BadgeDisplayKind.private,
      secondaryIndex = null;

  const _BadgeDisplayChoice.secondary(this.secondaryIndex)
    : kind = _BadgeDisplayKind.secondary;
}

class _BadgeDisplayPicker extends StatelessWidget {
  final String badgeId;
  final String? featuredId;
  final List<String> secondaryIds;

  const _BadgeDisplayPicker({
    required this.badgeId,
    required this.featuredId,
    required this.secondaryIds,
  });

  @override
  Widget build(BuildContext context) {
    final badge = BadgeCatalog.byId(badgeId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge?.name ?? 'Choose placement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how you’d like to display this badge. You can change this later.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Set as featured badge'),
              subtitle: Text(
                featuredId == null || featuredId!.isEmpty
                    ? 'Shown prominently on your profile.'
                    : 'Replaces your current featured badge.',
              ),
              onTap: () =>
                  Navigator.pop(context, const _BadgeDisplayChoice.featured()),
            ),

            const Divider(),

            Text(
              'Secondary badges (up to 3)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            for (int i = 0; i < 3; i++)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text('Place in secondary slot ${i + 1}'),
                subtitle: Text(
                  i < secondaryIds.length && secondaryIds[i].trim().isNotEmpty
                      ? 'Replaces current badge in this slot.'
                      : 'Adds to an empty slot.',
                ),
                onTap: () =>
                    Navigator.pop(context, _BadgeDisplayChoice.secondary(i)),
              ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('Accept but keep private'),
              subtitle: const Text(
                'Saved to your badge list, not shown publicly.',
              ),
              onTap: () =>
                  Navigator.pop(context, const _BadgeDisplayChoice.private()),
            ),
          ],
        ),
      ),
    );
  }
}
