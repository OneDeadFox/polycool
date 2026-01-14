import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../matches/controllers/matches_controller.dart';

import '../../../app/theme/app_colors.dart';
import '../../profile/models/profile.dart';
import '../../profile/models/reflection.dart';

/// UI-first v1: other user profile view.
/// - No badge mentions
/// - No activity visibility controls
/// - Like + Super Like action row
class OtherProfileScreen extends StatefulWidget {
  final Profile profile;
  final List<ReflectionInsight> reflections;

  // v1: pass in whether viewer has super likes available
  final int superLikesAvailable;
  final bool viewerIsSubscriber;

  const OtherProfileScreen({
    super.key,
    required this.profile,
    required this.reflections,
    this.superLikesAvailable = 0,
    this.viewerIsSubscriber = false,
  });

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  int _photoIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSuperLikePressed() async {
    if (widget.superLikesAvailable > 0) {
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

      // v1 stub: you’ll later wire this to Matches/Chat + local state.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message == null || message.isEmpty
                ? 'Super Like sent.'
                : 'Super Like sent with message.',
          ),
        ),
      );
      return;
    }

    // Out of super likes: subscriber vs non-subscriber dialog
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Out of Super Likes'),
          content: Text(
            widget.viewerIsSubscriber
                ? 'You can buy more now, or wait until they replenish on renewal.'
                : 'You can buy Super Likes now, or upgrade for replenishing Super Likes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Not now'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase flow (stub)')),
                );
              },
              child: const Text('Buy Super Likes'),
            ),
            if (!widget.viewerIsSubscriber)
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upgrade flow (stub)')),
                  );
                },
                child: const Text('Upgrade'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<MatchesController>().simulateMatch(
                widget.profile,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulated match. Added to Matches.'),
                ),
              );
            },
            child: const Text('Simulate match'),
          ),
        ],
        title: const Text('Profile'),
      ),

      // Bottom actions (always visible)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liked (stub).')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Like'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _onSuperLikePressed,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Super Like'),
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Name row (left: name,age) (right: location)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: _NameRow(profile: p),
          ),

          // Edge-to-edge carousel
          AspectRatio(
            aspectRatio: 1,
            child: _PhotoCarousel(
              profile: p,
              controller: _pageController,
              index: _photoIndex,
              onIndexChanged: (i) => setState(() => _photoIndex = i),
            ),
          ),

          // Demographics bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _DemographicsBar(profile: p),
          ),

          // About (optional)
          if ((p.about ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('About me'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                p.about!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],

          // Interests
          if (p.interests.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Interests'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InlineChips(values: p.interests),
            ),
          ],

          // Reflections (compact single section)
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle('Community reflections'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ReflectionsCompactSection(insights: widget.reflections),
          ),

          // Sexual preferences (only show if user enabled + has prefs)
          if (p.showPreferences && p.preferences.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Sexual preferences'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SexualPreferencesCompact(profile: p),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/* ───────────────────────── UI PARTS ───────────────────────── */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _NameRow extends StatelessWidget {
  final Profile profile;
  const _NameRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final ageSuffix = profile.age != null ? ', ${profile.age}' : '';
    final left = '${profile.displayName}$ageSuffix';
    final loc = (profile.location ?? '').trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            left,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (loc.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            loc,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}

class _DemographicsBar extends StatelessWidget {
  final Profile profile;
  const _DemographicsBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <String>[];

    final pronouns = (profile.pronouns ?? '').trim();
    if (pronouns.isNotEmpty) items.add(pronouns);

    if (profile.relationshipContextTags.isNotEmpty) {
      items.addAll(profile.relationshipContextTags);
    }

    if (profile.seeking.isNotEmpty) {
      items.addAll(profile.seeking);
    }

    if (items.isEmpty) {
      return Text(
        'No demographics listed.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(t, style: Theme.of(context).textTheme.bodySmall),
        );
      }).toList(),
    );
  }
}

class _InlineChips extends StatelessWidget {
  final List<String> values;
  const _InlineChips({required this.values});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((v) => Chip(label: Text(v))).toList(),
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  final Profile profile;
  final PageController controller;
  final int index;
  final ValueChanged<int> onIndexChanged;

  const _PhotoCarousel({
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
            final p = photos[i];
            final path = p.localPath;

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
            bottom: 12,
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
      ],
    );
  }
}

class _ReflectionsCompactSection extends StatelessWidget {
  final List<ReflectionInsight> insights;
  const _ReflectionsCompactSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (int i = 0; i < insights.length; i++) ...[
            _ReflectionRow(insight: insights[i]),
            if (i != insights.length - 1) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _ReflectionRow extends StatelessWidget {
  final ReflectionInsight insight;
  const _ReflectionRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    final clamped = insight.barValue.clamp(0.0, 0.9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleFor(insight.categoryKey),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: clamped,
          backgroundColor: Colors.white.withOpacity(0.8),
          color: AppColors.sparkExplore,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Text(insight.statement, style: Theme.of(context).textTheme.bodySmall),
        if (insight.gentlePrompt != null) ...[
          const SizedBox(height: 6),
          Text(
            insight.gentlePrompt!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  String _titleFor(String key) {
    switch (key) {
      case ReflectionCategories.communication:
        return 'Communication';
      case ReflectionCategories.reliability:
        return 'Reliability';
      case ReflectionCategories.personality:
        return 'Personality';
      case ReflectionCategories.reflection:
        return 'Reflection';
      default:
        return key;
    }
  }
}

class _SexualPreferencesCompact extends StatelessWidget {
  final Profile profile;
  const _SexualPreferencesCompact({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: const Text('Tap to view'),
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: profile.preferences.map((p) {
              final intensity = _intensityLabel(p.intensity.name);
              return Chip(label: Text('${p.label} • $intensity'));
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'This section reflects preferences not obligations.',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  String _intensityLabel(String key) {
    switch (key) {
      case 'curious':
        return 'Curious';
      case 'enjoys':
        return 'Enjoys';
      case 'deeplyEnjoys':
        return 'Deeply enjoys';
      case 'favorite':
        return 'Favorite';
      default:
        return key;
    }
  }
}
