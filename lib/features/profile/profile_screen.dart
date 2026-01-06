import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';

import 'badges/badges_screen.dart';

import 'models/reflection_insight.dart';
import 'models/profile.dart';

import 'widgets/profile_header.dart';
import 'widgets/reflection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const me = Profile(
  displayName: 'Alex',
  pronouns: 'they/them',
  featuredBadgeId: 'clear_communicator',
  secondaryBadgeIds: [
    'consent_forward',
    'compassionate_presence',
    'keeps_commitments',
  ],
);


  static const insights = <ReflectionInsight>[
    ReflectionInsight(
      title: 'Communication style',
      statement: 'Users say Alex communicates clearly and thoughtfully.',
      value: 0.78,
      prompt:
          'If your styles differ, it may help to talk about response time and check-ins.',
    ),
    ReflectionInsight(
      title: 'Emotional presence',
      statement:
          'Users often experience Alex as gentle and emotionally present.',
      value: 0.62,
    ),
    ReflectionInsight(
      title: 'Reliability',
      statement:
          'Users say Alex is usually clear about availability and follow-through.',
      value: 0.35,
      prompt:
          'If consistency matters to you, discussing schedules and expectations early can help.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _TopBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeader(
            profile: me,
            onTapAvatar: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BadgesScreen(profile: me)),
              );
            },
          ),

          const SizedBox(height: 18),

          const SectionHeader(
            title: 'Community reflection',
            subtitle: 'Patterns over time — not judgments.',
          ),

          ...insights.expand(
            (i) => [
              ReflectionCard(
                title: i.title,
                statement: i.statement,
                value: i.value,
                prompt: i.prompt,
              ),
              const SizedBox(height: 12),
            ],
          ),

          const SizedBox(height: 10),

          const _Section(
            title: 'Help shape this space',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggest features, propose badges, or report bugs anytime.',
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ActionChip(
                      icon: Icons.lightbulb_outline,
                      label: 'Suggest a feature',
                    ),
                    _ActionChip(
                      icon: Icons.bug_report_outlined,
                      label: 'Report a bug',
                    ),
                    _ActionChip(
                      icon: Icons.forum_outlined,
                      label: 'Community discussions',
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

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: wire to feedback flow later
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
