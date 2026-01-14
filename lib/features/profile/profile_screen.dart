import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';

import 'controllers/profile_controller.dart';
import 'controllers/reflection_controller.dart';
import 'models/profile.dart';
import 'models/reflection.dart';

import '../settings/settings_screen.dart';

import 'profile_setup/profile_setup_screen.dart';
import 'photos/my_photos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().me;
    final reflections = context.watch<ReflectionController>().orderedInsights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity visibility controls coming later.'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileSetupScreen(isEdit: true),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1) Display name
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: _NameRow(profile: profile),
          ),

          // 2) Photo carousel (edge-to-edge)
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyPhotosScreen()));
            },
            child: const AspectRatio(
              aspectRatio: 1,
              child: _ProfilePhotoCarousel(),
            ),
          ),

          // 3) Demographics bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _DemographicsBar(profile: profile),
          ),

          // About me (between demographics and interests)
          if (profile.about != null && profile.about!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('About me'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                profile.about!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],

          // 4) Interests
          if (profile.interests.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Interests'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InlineChips(values: profile.interests),
            ),
          ],

          // 5) Community reflections (compact single section)
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle('Community reflections'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ReflectionsCompactSection(insights: reflections),
          ),

          // 6) Sexual preferences (collapsed by default, blends in)
          if (profile.preferences.isNotEmpty ||
              profile.showPreferences == false) ...[
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Sexual preferences'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SexualPreferencesCompact(profile: profile),
            ),
          ],

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/* ───────────────────────── SECTIONS ───────────────────────── */

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

class _InlineChips extends StatelessWidget {
  final List<String> values;
  const _InlineChips({required this.values});

  @override
  Widget build(BuildContext context) {
    // Blended: no card, no border; relies on spacing + typography.
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((v) => Chip(label: Text(v))).toList(),
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
        'Add pronouns, relationship context, age, or location in Edit Profile.',
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

/* ───────────────────── PHOTO CAROUSEL ───────────────────── */

class _ProfilePhotoCarousel extends StatefulWidget {
  const _ProfilePhotoCarousel();

  @override
  State<_ProfilePhotoCarousel> createState() => _ProfilePhotoCarouselState();
}

class _ProfilePhotoCarouselState extends State<_ProfilePhotoCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().me;
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
          controller: _controller,
          itemCount: photos.length,
          onPageChanged: (i) => setState(() => _index = i),
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
                    final active = i == _index;
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

/* ───────────────────── REFLECTIONS (COMPACT) ───────────────────── */

class _ReflectionsCompactSection extends StatelessWidget {
  final List<ReflectionInsight> insights;
  const _ReflectionsCompactSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    // One unified panel: 4 compact rows.
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
    final title = _titleFor(insight.categoryKey);
    final clamped = insight.barValue.clamp(0.0, 0.9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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

/* ───────────────────── SEXUAL PREFERENCES (COMPACT) ───────────────────── */

class _SexualPreferencesCompact extends StatelessWidget {
  final Profile profile;
  const _SexualPreferencesCompact({required this.profile});

  @override
  Widget build(BuildContext context) {
    final visible = profile.showPreferences && profile.preferences.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: !visible
          ? Text(
              'Hidden. You can enable this in Edit Profile.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : ExpansionTile(
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
