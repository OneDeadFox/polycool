import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../shared/controllers/monetization_controller.dart';

import '../matches/controllers/matches_controller.dart';
import '../profile/controllers/reflection_controller.dart';
import '../profile/models/profile.dart';
import '../profile/other_profile/other_profile_screen.dart';

import 'discover_controller.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final PageController _carousel = PageController();

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  void _clearUndo(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void _jumpToIndex(int i) {
    if (!_carousel.hasClients) return;
    if (i < 0) i = 0;
    _carousel.animateToPage(
      i,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final discover = context.watch<DiscoverController>();
    final monetization = context.watch<MonetizationController>();
    final matches = context.read<MatchesController>();

    final list = discover.visible;
    final reflections = context.read<ReflectionController>().orderedInsights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Dev: Reset Discover',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              _clearUndo(context);

              await context.read<DiscoverController>().devResetDiscover();
              await context.read<MatchesController>().devClearLikes();

              if (!mounted) return;

              // Reset carousel back to first card
              if (_carousel.hasClients) {
                _carousel.jumpToPage(0);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discover reset (dev).')),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'No profiles to show right now.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : PageView.builder(
                      controller: _carousel,
                      onPageChanged: (i) {
                        _clearUndo(context);
                        discover.setIndex(i);
                      },
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final profile = list[i];

                        return GestureDetector(
                          onTap: () {
                            _clearUndo(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OtherProfileScreen(
                                  profile: profile,
                                  reflections: reflections,
                                  superLikesAvailable: monetization.superLikes,
                                  viewerIsSubscriber: monetization.isSubscriber,
                                ),
                              ),
                            );
                          },
                          child: _DiscoverCard(profile: profile),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 14),

            // Inline actions: X, Like, Super Like
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: list.isEmpty
                        ? null
                        : () async {
                            _clearUndo(context);
                            final nextIndex = await discover
                                .dismissCurrentForTwoWeeks();

                            if (discover.visible.isNotEmpty) {
                              _jumpToIndex(nextIndex);
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 10),
                                content: const Text(
                                  'Removed from your feed for 2 weeks.',
                                ),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () async {
                                    await discover.undoLastDismiss();
                                    if (discover.visible.isNotEmpty) {
                                      _jumpToIndex(discover.index);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.close),
                    label: const Text('X'),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: list.isEmpty
                        ? null
                        : () async {
                            _clearUndo(context);

                            final current = discover.current;
                            await matches.like(current);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Liked.')),
                            );

                            final next = (discover.index + 1).clamp(
                              0,
                              discover.visible.length - 1,
                            );
                            _jumpToIndex(next);
                          },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Like'),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sparkDating,
                    ),
                    onPressed: list.isEmpty
                        ? null
                        : () async {
                            _clearUndo(context);
                            final current = discover.current;

                            await _handleSuperLike(
                              context,
                              monetization,
                              matches,
                              current,
                              onSent: () {
                                final next = (discover.index + 1).clamp(
                                  0,
                                  discover.visible.length - 1,
                                );
                                _jumpToIndex(next);
                              },
                            );
                          },
                    icon: const Icon(Icons.auto_awesome),
                    label: Text('Super Like (${monetization.superLikes})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSuperLike(
    BuildContext context,
    MonetizationController monetization,
    MatchesController matches,
    Profile current, {
    required VoidCallback onSent,
  }) async {
    if (monetization.superLikes > 0) {
      final message = await showDialog<String?>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Send a Super Like'),
            content: TextField(
              controller: ctrl,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Optional message (200 chars max)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Send'),
              ),
            ],
          );
        },
      );

      if (message == null) return;

      // Record super like + optional message
      await matches.superLike(current, message: message);

      // Consume super like token
      await monetization.consumeSuperLike();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? 'Super Like sent.'
                : 'Super Like sent with message.',
          ),
        ),
      );

      onSent();
      return;
    }

    // Out of super likes dialog
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isSub = monetization.isSubscriber;
        return AlertDialog(
          title: const Text('Out of Super Likes'),
          content: Text(
            isSub
                ? 'You can buy more now, or wait until they replenish. (${monetization.daysUntilRenewal} days)'
                : 'You can buy Super Likes now, or upgrade for replenishing Super Likes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Not now'),
            ),
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await monetization.addSuperLikes(3);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchased 3 Super Likes (stub).'),
                  ),
                );
              },
              child: const Text('Buy Super Likes'),
            ),
            if (!isSub)
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await monetization.setSubscriber(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upgraded (stub).')),
                  );
                },
                child: const Text('Upgrade'),
              ),
          ],
        );
      },
    );
  }
}

/* ───────────────────────── CARD ───────────────────────── */

class _DiscoverCard extends StatefulWidget {
  final Profile profile;
  const _DiscoverCard({required this.profile});

  @override
  State<_DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<_DiscoverCard> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    final ageSuffix = p.age != null ? ', ${p.age}' : '';
    final leftTitle = '${p.displayName}$ageSuffix';
    final loc = (p.location ?? '').trim();

    final chips = <String>[];
    final pronouns = (p.pronouns ?? '').trim();
    if (pronouns.isNotEmpty) chips.add(pronouns);
    if (p.relationshipContextTags.isNotEmpty)
      chips.addAll(p.relationshipContextTags);
    if (p.seeking.isNotEmpty) chips.addAll(p.seeking);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: _PhotoPreview(
              profile: p,
              controller: _page,
              index: _index,
              onIndexChanged: (i) => setState(() => _index = i),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        leftTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (loc.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(
                        loc,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips.take(8).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.sparkDating,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to view full profile',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final Profile profile;
  final PageController controller;
  final int index;
  final ValueChanged<int> onIndexChanged;

  const _PhotoPreview({
    required this.profile,
    required this.controller,
    required this.index,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final photos = profile.photos;

    if (photos.isEmpty) {
      return Container(
        color: AppColors.surfaceMuted,
        child: const Center(child: Icon(Icons.person_outline, size: 56)),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: controller,
          itemCount: photos.length,
          onPageChanged: onIndexChanged,
          itemBuilder: (context, i) {
            final photo = photos[i];
            final path = photo.localPath;

            if (path != null && File(path).existsSync()) {
              return Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }

            return Container(
              color: AppColors.surfaceMuted,
              child: const Center(child: Icon(Icons.image_outlined, size: 44)),
            );
          },
        ),
        if (photos.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(photos.length, (i) {
                    final active = i == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(active ? 0.95 : 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(height: 4, color: AppColors.sparkDating),
        ),
      ],
    );
  }
}
